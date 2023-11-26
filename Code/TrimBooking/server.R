library(shiny)
library(shinydashboard)
library(DT)
library(readxl)
library(openxlsx)
library(dplyr)
library(janitor)

shinyServer(function(input, output, session) {
    output$invoice_files <- DT::renderDT({
        DT::datatable(input$upload_invoice, selection = "single")
    })
    
    
    # read all the uploaded files
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
    
    #########################
    output$plm_output_file <- DT::renderDT({
        DT::datatable(plm_file(), selection = "single")
    })
    
    # read the uploaded file
    plm_file <- reactive({
        req(input$upload_plm_data)
        read_excel(input$upload_plm_data$datapath)
    })
    
    # select a row in DT files and display the corresponding table
    output$selected_plm_table <- renderTable({
        req(input$plm_output_file_rows_selected)
        
        plm_file()[input$plm_output_file_rows_selected, ]
    })
    
    
    
    ####################3
    modified_data <- reactiveVal(NULL)
    
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
                necessary_cols <- c("Style Number", "Style Number TB", "Colors", "Colour")
                Order_Summary <- quentity %>%
                    select(necessary_cols, "UNITS")
                
                # Initialize Total_Order_Summary if it's the first iteration
                if(counter == 0){
                    Total_Order_Summary <- quentity %>% 
                        select(necessary_cols)
                    
                    Total_Order_Summary[, size_cols] <- 0
                    counter = 1
                }
                
                #Total_Order_Summary[5] <- Total_Order_Summary[5] + quentity[5]
                
                # Perform calculations and update the new data frame
                for (i in 6:13) {
                    Order_Summary[size_cols[i - 4]] <- ceiling(quentity[[i]] * quentity[[5]])
                    Total_Order_Summary[i] <- (Total_Order_Summary[i] + Order_Summary[i])
                }
             
                 # Save the modified data to the list
                 processed_data_list[[file_index]] <- Order_Summary
            }
            
            for (i in 6:13) {
                Total_Order_Summary[i] <- ceiling(Total_Order_Summary[i] * (100+input$buffer)/100)
            }
            
            # Combine all processed data frames into a single data frame
            # combined_data <- bind_rows(processed_data_list)
            
            # Save the combined data
            modified_data(Total_Order_Summary)
        }
    })
    
    
    output$totalOrderQty <- DT::renderDT({
        DT::datatable(modified_data(), selection = "single")
    })
    
    
    
    #select a row in DT files and display the corresponding table
    output$total_order_qty <- renderTable({
        req(input$totalOrderQty_rows_selected)
        
        destinationQty_files()[[input$totalOrderQty_rows_selected]]
    })
    
    output$dlTotal_Order_Qty <- downloadHandler(
        filename = function() {"Order_Summary.xlsx"},
        content = function(excel_file) {
            write.xlsx(modified_data(), excel_file, rowNames = FALSE)}
    )
    
    ###################################################3
    
    TotalRM_data <- reactiveVal(NULL)
    
    observeEvent(input$process_RMQty, {
        if (!is.null(plm_file())) {
            
            plm_data <- plm_file()
            plm_data <- plm_data %>% mutate(Style_Color = toupper(plm_data$`Color`), .keep = "unused")
            
            Total_Order_Summary <-  modified_data() %>% rename(Style_Color = Colors)
            
            
            merged_df <- merge(x = plm_data, y = Total_Order_Summary,
                               by = c("Style Number", "Style_Color"),
                               all.x = T)
            
            result <- merged_df
            
            result[12:19] <- 0
            
            counter = 12
            for (i in 12:19) {
                result[counter] <- ceiling(merged_df[i] * merged_df$Consumption * (1+merged_df$Wastage))
                counter = counter + 1
            }
            
            result <- result %>% rename(Style_Number = `Style Number`)
            result <- result[result$Consumption != 0 | result$`RM Color` != "N/A",]
            
            
            result <- result %>%
                group_by(`RM Reference`, `RM Color`) %>%
                summarise(across(c(`3XS`, `2XS`, `XS`, `S`, `M`, `L`, `XL`, `2XL`), sum))
            
            
            # Save the combined data
            TotalRM_data(result)
        }
    })
    
    
    output$tRMQty_file <- DT::renderDT({
        DT::datatable(TotalRM_data(), selection = "single")
    })
    
    
    
    #select a row in DT files and display the corresponding table
    output$total_RM_qty <- renderTable({
        req(input$tRMQty_file_rows_selected)
        
        plm_file()[[input$tRMQty_file_rows_selected]]
    })
    
    output$dltotal_RM_qty <- downloadHandler(
        filename = function() {"Total_RM_Qty.xlsx"},
        content = function(excel_file) {
            write.xlsx(TotalRM_data(), excel_file, rowNames = FALSE)}
    )
    
    
})

