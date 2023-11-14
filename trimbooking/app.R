#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


ui <- fluidPage(
  titlePanel("Trim booking Automation"),
  sidebarLayout(
    sidebarPanel(strong(h3("Brows the Quantity file :")),
                 br(),
                 #fileInput("quantity_file", label = "Enter the Quantity file"),
                 fileInput('quantity_file',label = "Enter the Quantity file",accept = c(".xlsx")),
                 
                 strong(h3("Brows the PLM BOM file :")),
                 #fileInput("BOM_file", label = "Enter the BOM file"),
                 fileInput('BOM_file',label = "Enter the BOM file",accept = c(".xlsx")),
                 
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Quantity file" ,tableOutput("table1")),
        tabPanel("PLM BOM file"  ,tableOutput("table2")))
    )
    
  )
)


server <- function(input, output) {
  output$table1 <- renderTable({
    inFile <- input$quantity_file
    if(is.null(inFile))
      return(NULL)
    readxl::read_excel(inFile$datapath)})
  
  
  
  # Function to read Excel file
  data <- reactive({
    req(input$quantity_file)
    excel_file <- read_excel(input$quantity_file$datapath, sheet = input$sheet)
    return(excel_file)
  })
  
  # Render the table
  output$table1 <- renderTable({
    data()
  })
  
  # Perform calculations and display the result
  observeEvent(input$calculate, {
    data_df <- data()
    value <- input$value
    result <- sum(data_df$value) * value
    output$result <- renderText({
      paste("Result of calculation: ", result)
    })
  })
  
}


shinyApp(ui = ui, server = server)
