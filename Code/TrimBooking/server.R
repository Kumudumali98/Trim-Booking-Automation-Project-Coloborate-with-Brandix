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
            
            # Extract a specific data frame from the list
            quentity <- all_files()[[1]]  # Adjust the index based on your data structure
            
            # Replace NA values with 0 in specified columns
            quentity <- quentity %>%
                mutate_at(size_cols, ~replace(., is.na(.), 0))
            
            # Print the 'quentity' data frame for debugging
            #print("Printing 'quentity' data frame:")
            #print(quentity)
            
            # Extract necessary columns to a new data frame
            necessary_cols <- c("Style Number", "Style Number TB", "Colors", "Colour")
            Order_Summary <- quentity %>%
                select(necessary_cols, "UNITS")
            
            # Perform calculations and update the new data frame
            for (i in 6:13) {
                Order_Summary[size_cols[i - 4]] <- ceiling(quentity[[i]] * quentity[[5]])
            }
            
            # Print the 'Order_Summary' data frame for debugging
           # print("Printing 'Order_Summary' data frame:")
            #print(Order_Summary)
            
            # Save the modified data
            modified_data(Order_Summary)
        }
    })
    
    # Display the modified table
    output$modifiedTable <- renderTable({
        if (!is.null(modified_data())) {
            modified_data()
        }
    }, caption = "Modified Table")
    
})

