library(shiny)
library(shinydashboard)
library(DT)
library(readxl)
library(openxlsx)
library(dplyr)
library(janitor)

shinyUI(dashboardPage(
    skin = "red",
    dashboardHeader(title = "Brandix - Trim Booking Automation",titleWidth = 350),
    dashboardSidebar(
        width = 350,
        
        sidebarMenu(
            menuItem("Home", tabName = "home", icon = icon("home", style = "padding-right:10px;")),
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
                    tabName = "home", 
                    h3(strong("Welcome To Trim Booking Automation")),
                    hr(),
                    p(style="text-align: justify; font-size : 16px;",
                      "This online application was designed to automate the trim 
                      booking process for Brandix by focusing on critical 
                      calculations such as total garment quantity, total 
                      trim quantity at the trim booking and order confirmation 
                      phases, and comparative trim quantity data analysis. Go to",
                      a(href = "https://github.com/Kumudumali98/MT-325-Trim-Booking-Group.git",
                        "Trim Bookning Automation GitHub Page"),
                      "to find more details on the source code."),
                    hr(),
                    tags$blockquote("Shiny-Box is still under continuous development. Please look forward to future updates!"),
                    hr(),
                    tags$div(
                        style = "text-align: center;",  
                        imageOutput("home_img")
                    ),
                ),
                tabItem(
                    tabName = "invoice", 
                    h3("Upload Invoice"),
                    textInput("invoiceNumber", "Enter Invoice Number"),
                    fileInput("upload_invoice", NULL, buttonLabel = "Upload Perchase Order", multiple = TRUE),
                    h3("Enter Buffer"),
                    numericInput("buffer", "Enter Buffer value (%):", 2, min = 1, max = 100),
                    actionButton("process_order", "Process Order"),
                    h3("Upload PLM files", style="margin-bottom:25px;"),
                    fileInput("upload_plm_data", NULL, buttonLabel = "Upload PLM BOM", multiple = FALSE),
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
                    downloadButton("dlTotal_Order_Qty_w_buffer", "Download")
                ),
                tabItem(
                    tabName = "totalRMQty",
                    tableOutput("total_RM_qty"),
                    
                    downloadButton("dlTotal_RM_Qty", "Download")
                ),
                tabItem(
                    tabName = "comparison",
                    h3("Enter Trim Booking Raw Material Order File"),
                    fileInput("upload_file1", NULL, buttonLabel = "Upload", multiple = FALSE),
                    h3("Enter  Trim Booking Raw Material Confirmed Order File"),
                    fileInput("upload_file2", NULL, buttonLabel = "Upload", multiple = FALSE),
                    actionButton("process_comparison", "Comparison"),
                    tableOutput("comparison"),
                    downloadButton("dl_comparison", "Download")
                )
        )
    )
        
))
    
