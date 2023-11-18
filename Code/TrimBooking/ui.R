library(shiny)
library(readxl)
library(shinydashboard)

shinyUI(dashboardPage(
    dashboardHeader(title = "Invoice App"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Upload Invoice", tabName = "upload", icon = icon("cloud-upload")),
            menuItem("Details", tabName = "details", icon = icon("info"))
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(
                tabName = "upload",
                h2("Upload Invoice"),
                fileInput("file", "Choose Excel File", accept = c(".xlsx")),
                textInput("invoiceNumber", "Enter Invoice Number"),
                textInput("destinationName", "Enter Destination Name"),
                actionButton("processBtn", "Process Invoice")
            ),
            tabItem(
                tabName = "details",
                h2("Details"),
                tableOutput("invoiceTableDetails")
            )
        )
    )
    
))

