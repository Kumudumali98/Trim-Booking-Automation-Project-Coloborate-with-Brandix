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
  
  output$table2 <- renderTable({
    inFile <- input$BOM_file
    if(is.null(inFile))
      return(NULL)
    readxl::read_excel(inFile$datapath)})
}


shinyApp(ui = ui, server = server)
