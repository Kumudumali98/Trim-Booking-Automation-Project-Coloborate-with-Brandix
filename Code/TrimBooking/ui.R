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
            menuItem("Total Garment Order", tabName = "totalGarmentOrder", icon = icon("info")),
            menuItem("Total Raw Material Quantity", tabName = "totalRMQty", icon = icon("info")),
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
                numericInput("buffer", "Buffer (%):", 0, min = 1, max = 100),
                actionButton("process_order", "Process Order"),
                fileInput("upload_plm_data", NULL, buttonLabel = "Upload PLM B...", multiple = FALSE),
                actionButton("process_RMQty", "Process Raw Material Quantity")
            ),
            tabItem(
                tabName = "data",
                DT::DTOutput("invoice_files"),
                tableOutput("selected_invoice_table"),
                
                DT::DTOutput("plm_output_file"),
                tableOutput("selected_plm_table")
            ),
            tabItem(
                tabName = "totalGarmentOrder",
                DT::DTOutput("totalOrderQty"),
                tableOutput("total_order_qty"),
                
                downloadButton("dlTotal_Order_Qty", "Download")
            ),
            tabItem(
                tabName = "totalRMQty",
                DT::DTOutput("tRMQty_file"),
                tableOutput("total_RM_qty"),
                
                downloadButton("dlTotal_RM_Qty", "Download")
            ),
            tabItem(
                tabName = "comparison"
                # Add UI elements specific to the "Results" tab here
            )
        )
    )
    
))

