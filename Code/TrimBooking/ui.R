library(shiny)
library(shinydashboard)
library(DT)
library(readxl)
library(openxlsx)
library(dplyr)
library(janitor)

shinyUI(dashboardPage(
    dashboardHeader(title = "Invoice App"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Upload Invoice", tabName = "invoice", icon = icon("cloud-upload")),
            menuItem("Data", tabName = "data", icon = icon("info")),
            menuItem("Results", tabName = "results", icon = icon("info")),
            menuItem("Comparison", tabName = "comparison", icon = icon("info"))
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(
                tabName = "invoice", 
                h2("Upload Invoice"),
                textInput("invoiceNumber", "Enter Invoice Number"),
                fileInput("upload_invoice", NULL, buttonLabel = "Upload Invoice...", multiple = TRUE),
                actionButton("processBtn", "Process Invoice")
            ),
            tabItem(
                tabName = "data",
                DT::DTOutput("invoice_files"),
                tableOutput("selected_invoice_table")
            ),
            tabItem(
                tabName = "results",
                DT::DTOutput("result_files"),
                tableOutput("selected_prosessed_table"),
                
                downloadButton("dl", "Download")
            ),
            tabItem(
                tabName = "comparison"
                # Add UI elements specific to the "Results" tab here
            )
        )
    )
    
))

