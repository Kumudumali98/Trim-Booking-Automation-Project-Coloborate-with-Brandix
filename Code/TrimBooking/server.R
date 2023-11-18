library(shiny)
library(readxl)
library(shinydashboard)

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
})

