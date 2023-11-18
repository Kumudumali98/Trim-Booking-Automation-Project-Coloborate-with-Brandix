library(shiny)
library(readxl)
library(shinydashboard)

shinyServer(function(input,output) {
    data <- reactiveVal(NULL)
    
    observeEvent(input$processBtn, {
        req(input$file, input$invoiceNumber, input$destinationName)
        
        # Read the uploaded Excel file
        inFile <- input$file
        df <- read_excel(inFile$datapath)
        
        # Check if the 'Destination' column exists in the data
        if ('Destination' %in% colnames(df)) {
            # Filter data based on the given destination name
            filtered_df <- df[df$Destination == input$destinationName, ]
            
            # Store data in the reactive value for later use
            data(filtered_df)
        } else {
            # If 'Destination' column is not present, use the entire data
            data(df)
        }
    })
    
    observe({
        df <- data()
        
        # Display the details in the "Details" tab
        output$invoiceTableDetails <- renderTable({
            df
        })
    })
})

