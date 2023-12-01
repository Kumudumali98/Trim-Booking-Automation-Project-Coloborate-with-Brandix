library(shiny)
library(shinydashboard)
library(DT)
library(readxl)
library(openxlsx)
library(dplyr)
library(janitor)

shinyUI(dashboardPage(
    skin = "red",
    dashboardHeader(title = "Brandix Trim Booking Calculator",titleWidth = 350),
    dashboardSidebar(
        width = 350,
        
        sidebarMenu(
            menuItem("Upload Invoice", tabName = "invoice", icon = icon("cloud-upload", style = "padding-right:10px;")),
            menuItem("Data", tabName = "data", icon = icon("table", style = "padding-right:10px;")),
            menuItem("Total Garment Order", tabName = "totalGarmentOrder", icon = icon("arrow-down-a-z", style = "padding-right:10px;")),
            menuItem("Total Raw Material Quantity", tabName = "totalRMQty", icon = icon("arrow-down-1-9", style = "padding-right:10px;")),
            menuItem("Comparison", tabName = "comparison", icon = icon("code-compare", style = "padding-right:10px;"))
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
                tableOutput("total_order_qty"),
                
                downloadButton("dlTotal_Order_Qty_w_buffer", "with buffer Download"),
                downloadButton("dlTotal_Order_Qty_wo_buffer", "without buffer Download")
            ),
            tabItem(
                tabName = "totalRMQty",
                tableOutput("total_RM_qty"),
                
                downloadButton("dlTotal_RM_Qty", "with buffer Download"),
                downloadButton("dlTotal_RM_Qty_wo_buffer", "without buffer Download")
            ),
            tabItem(
                tabName = "comparison",
                fileInput("upload_file1", NULL, buttonLabel = "Upload Initial Order...", multiple = FALSE),
                fileInput("upload_file2", NULL, buttonLabel = "Upload Confiremed Order ...", multiple = FALSE),
                actionButton("process_comparison", "Comparison"),
                tableOutput("comparison"),
                downloadButton("dl_comparison", "Download")
            )
        )
    )
    
))

