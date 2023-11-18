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
    all_files <- reactive({
        req(input$upload_invoice)
        purrr::map(input$upload_invoice$datapath, read_excel) %>%
            purrr::set_names(input$upload_invoice$name)
    })
    
    #select a row in DT files and display the corresponding table
    output$selected_invoice_table <- renderTable({
        req(input$invoice_files_rows_selected)
        
        all_files()[[input$invoice_files_rows_selected]]
    })
    
    
    modified_data <- reactiveVal(NULL)
    
    observeEvent(input$processBtn, {
        if (!is.null(all_files())) {
            # Your existing code
            counter = 0
            size_cols <- c("UNITS", "3XS", "2XS", "XS", "S", "M", "L", "XL", "2XL")
            
            # Initialize an empty list to store processed data frames
            processed_data_list <- list()
            
            # Loop through all the uploaded files
            for (file_index in seq_along(all_files())) {
                # Extract a specific data frame from the list
                quentity <- all_files()[[file_index]]
                
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
                
                Total_Order_Summary[5] <- Total_Order_Summary[5] + quentity[5]
                
                # Perform calculations and update the new data frame
                for (i in 6:13) {
                    Order_Summary[size_cols[i - 4]] <- ceiling(quentity[[i]] * quentity[[5]])
                    Total_Order_Summary[i] <- ceiling((Total_Order_Summary[i] + Order_Summary[i])*1.02)
                }
                
                # Save the modified data to the list
                processed_data_list[[file_index]] <- Order_Summary
            }
            
            # Combine all processed data frames into a single data frame
            combined_data <- bind_rows(processed_data_list)
            
            # Save the combined data
            modified_data(Total_Order_Summary)
        }
    })
    
    
    output$result_files <- DT::renderDT({
        DT::datatable(modified_data(), selection = "single")
    })
    
    
    
    #select a row in DT files and display the corresponding table
    output$selected_prosessed_table <- renderTable({
        req(input$result_files_rows_selected)
        
        all_files()[[input$result_files_rows_selected]]
    })
    
    output$dl <- downloadHandler(
        filename = function() {"Order_Summary.xlsx"},
        content = function(excel_file) {
            write.xlsx(modified_data(), excel_file, rowNames = FALSE)}
    )
    
})

