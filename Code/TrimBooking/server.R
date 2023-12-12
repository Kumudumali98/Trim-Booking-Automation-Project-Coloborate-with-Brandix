library(shiny)
library(shinydashboard)
library(DT)
library(readxl)
library(openxlsx)
library(dplyr)
library(janitor)

shinyServer(function(input, output, session) {
    
    # Render the Brandix logo image
    output$home_img <- renderImage({
        list(id = "logoImage", src = "../../www/Logo.png",height = "183px", width="275px" )
    }, deleteFile = F)
    
    # Render the datatable for uploaded invoice files
    output$invoice_files <- DT::renderDT({
        DT::datatable(input$upload_invoice, selection = "single")
    })
    
    
    # read all the uploaded invoice files
    destinationQty_files <- reactive({
        req(input$upload_invoice)
        purrr::map(input$upload_invoice$datapath, read_excel) %>%
            purrr::set_names(input$upload_invoice$name)
    })
    
    #select a row in DT files and display the corresponding table
    output$selected_invoice_table <- renderTable({
        req(input$invoice_files_rows_selected)
        destinationQty_files()[[input$invoice_files_rows_selected]]
    })
    
    # Render the datatable for uploaded PLM BOM file
    output$plm_output_file <- DT::renderDT({
        DT::datatable(plm_file(), selection = "single")
    })
    
    # read the uploaded PLM BOM file
    plm_file <- reactive({
        req(input$upload_plm_data)
        read_excel(input$upload_plm_data$datapath)
    })
    
    # select a row in DT files and display the corresponding table
    output$selected_plm_table <- renderTable({
        req(input$plm_output_file_rows_selected)
        
        plm_file()[input$plm_output_file_rows_selected, ]
    })
    
    # Reactive value for total order summary with buffer
    total_Order_w_buffer_data <- reactiveVal(NULL)
    
    # Observe event for processing order data
    observeEvent(input$process_order, {
        if (!is.null(destinationQty_files())) {
            # Your existing code
            counter = 0
            size_cols <- c("UNITS", "3XS", "2XS", "XS", "S", "M", "L", "XL", "2XL")
            
            # Initialize an empty list to store processed data frames
            processed_data_list <- list()
            
            # Loop through all the uploaded files
            for (file_index in seq_along(destinationQty_files())) {
                # Extract a specific data frame from the list
                quentity <- destinationQty_files()[[file_index]]
                
                # Replace NA values with 0 in specified columns
                quentity <- quentity %>%
                    mutate_at(size_cols, ~replace(., is.na(.), 0))
                
                # Extract necessary columns to a new data frame
                necessary_cols <- c("Style Number","Colour")
                Order_Summary <- quentity %>%
                    select(necessary_cols, "UNITS")
                
                # Initialize Total_Order_Summary if it's the first iteration
                if(counter == 0){
                    Total_Order_Summary <- quentity %>% 
                        select(necessary_cols)
                    
                    Total_Order_Summary[, size_cols] <- 0
                    counter = 1
                }
                
                # Perform calculations and update the new data frame
                for (i in 4:11) {
                    Order_Summary[size_cols[i - 2]] <- ceiling(quentity[[i]] * quentity[[3]])
                    Total_Order_Summary[i] <- (Total_Order_Summary[i] + Order_Summary[i])
                }
                
                # Save the modified data to the list
                processed_data_list[[file_index]] <- Order_Summary
            }
            
            # Apply buffer to total order summary
            for (i in 4:11) {
                Total_Order_Summary[i] <- ceiling(Total_Order_Summary[i] * (100+input$buffer)/100)
            }
            
            # Save the combined data
            total_Order_w_buffer_data(Total_Order_Summary)
        }
    })
    
    
    # Render a table for the total order quantity with buffer
    output$total_order_qty <- renderTable(total_Order_w_buffer_data())
    
    # Download handler for total order quantity with buffer
    output$dlTotal_Order_Qty_w_buffer <- downloadHandler(
        filename = function() {"Order_Summary_with_buffer.xlsx"},
        content = function(excel_file) {
            write.xlsx(total_Order_w_buffer_data(), excel_file, rowNames = FALSE)}
    )
    
    # Reactive value for total raw material data
    TotalRM_data <- reactiveVal(NULL)
    
    # Observe event for processing raw material quantity data
    observeEvent(input$process_RMQty, {
        if (!is.null(plm_file())) {
            
            # Read and preprocess PLM data
            plm_data <- plm_file()
            plm_data <- plm_data %>% mutate(Style_Color = toupper(plm_data$`Color`), .keep = "unused")
            
            # Retrieve total order summary with buffer
            Total_Order_Summary <-  total_Order_w_buffer_data() 
            Total_Order_Summary <- Total_Order_Summary %>% 
                mutate(Style_Color = toupper(Total_Order_Summary$`Colour`), .keep = "unused")
            
            # Merge PLM data with total order summary
            merged_df <- merge(x = plm_data, y = Total_Order_Summary,
                               by = c("Style Number", "Style_Color"),
                               all.x = T)
            
            # Initialize result data frame
            result <- merged_df
            result[11:18] <- 0
            
            # Calculate raw material quantities
            counter = 11
            for (i in 11:18) {
                result[counter] <- ceiling(merged_df[i] * merged_df$Consumption * (1+merged_df$Wastage))
                counter = counter + 1
            }
            
            # Rename columns
            result <- result %>% rename(Style_Number = `Style Number`)
            result <- result[result$Consumption != 0 | result$`RM Color` != "N/A",]
            
            # Filter out unnecessary rows
            result <- result %>%
                group_by(`RM Reference`, `RM Color`) %>%
                summarise(across(c(`3XS`, `2XS`, `XS`, `S`, `M`, `L`, `XL`, `2XL`), sum))
            
            
            # Save the combined data
            TotalRM_data(result)
            
        }
    })
    
    
    # Render a table for the total raw material quantity
    output$total_RM_qty <- renderTable(TotalRM_data())
    
    # Download handler for total raw material quantity
    output$dlTotal_RM_Qty <- downloadHandler(
        filename = function() {"Total_RM_Qty.xlsx"},
        content = function(excel_file) {
            write.xlsx(TotalRM_data(), excel_file, rowNames = FALSE)
        }
    ) 
    
    
    # Reactive values for before and after confirmed files
    before_confirmed <- reactive({
        req(input$upload_file1)
        read_excel(input$upload_file1$datapath)
    })
    
    after_confirmed <- reactive({
        req(input$upload_file2)
        read_excel(input$upload_file2$datapath)
    })
    
    #Reactive value for storing comparison data
    Comparison_data <- reactiveVal(NULL)
    
    # Observe event for processing comparison data
    observeEvent(input$process_comparison, {
        if (!is.null(before_confirmed()) && !is.null(after_confirmed())) {
            
            # Extract data from before and after confirmed files
            before_con <- before_confirmed()
            after_con <- after_confirmed()
            
            # Select relevant columns for comparison
            comparison <- before_con %>% select(`RM Reference`, `RM Color`)
            
            # Calculate the differences for retail prices and quantities
            size_columns <- c("3XS", "2XS", "XS", "S", "M", "L", "XL", "2XL")
            for (col in size_columns) {
                comparison[[paste0(col, "_Diff.")]] <- after_con[col] - before_con[col]
            }
            
            # Save the combined data
            Comparison_data(comparison)
        }
    })
    
    
    # Render a table for the comparison data
    output$comparison <- renderTable(Comparison_data())
    
    # Download handler for the comparison data
    output$dl_comparison <- downloadHandler(
        filename = function() {"Comparison.xlsx"},
        content = function(excel_file) {
            write.xlsx(Comparison_data(), excel_file, rowNames = FALSE)
        }
    )
    
    
})