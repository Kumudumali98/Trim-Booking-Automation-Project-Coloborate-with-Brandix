
# Load necessary libraries
library(readxl)
library(openxlsx)
library(dplyr)

# Initialize a counter variable
counter = 0
size_cols <- c("UNITS", "3XS", "2XS", "XS", "S", "M", "L", "XL", "2XL")

# Start an infinite loop
repeat {
  
  # Ask the user for input
  user_input <- readline("Enter 'q' to quit or destination name to continue: ")
  
  # Check the termination condition
  if (user_input == "q") {
    cat("Exiting the loop.\n")
    break  # Exit the loop when the user enters 'q'
  }
  
  # Use file.choose() to open a file chooser dialog
  file_path <- file.choose()
  
  # Read the Excel file into a data frame
  quentity <- read_excel(file_path)

  # Change NA values to 0 in specified columns
  quentity <- quentity %>% 
    mutate_at(size_cols, ~replace(., is.na(.), 0))
  
  # Extract necessary columns to a new data frame
  necessary_cols <- c("Style Number", "Style Number TB", "Colors", "Colour")
  Order_Summary <- quentity %>% 
    select(necessary_cols, "UNITS")
  
  # Initialize Total_Order_Summary if it's the first iteration
  if(counter == 0){
    Total_Order_Summary <- quentity %>% 
      select(necessary_cols)
    
    Total_Order_Summary[, size_cols] <- 0
    counter = 1
  }
  
  Total_Order_Summary[5] <- Total_Order_Summary[5] + quentity[5]
  
  # Perform calculations and update the new data frame
  for (i in 6:13) {
    Order_Summary[size_cols[i-4]] <- ceiling(quentity[[i]] * quentity[[5]])
    Total_Order_Summary[i] <- Total_Order_Summary[i] + Order_Summary[i]
  }
  
  # Assign the new data frame to a variable with a user-defined name
  user_input <- paste0(user_input, "_Order_Summary")
  assign(user_input, Order_Summary)

  # Create the Excel filename based on user input
  excel_file <- paste0(user_input, ".xlsx")
  
  # Save Order_Summary as an Excel file
  write.xlsx(Order_Summary, excel_file, rowNames = FALSE)
  cat("Continuing the loop.\n")
}

# Uncomment this section if needed for additional calculations
for (i in 6:13) {
  Total_Order_Summary[i] <- ceiling(Total_Order_Summary[i] * 1.02)
}

# Specify the Excel file name for the final export
excel_file <- "Total_Order_Summary.xlsx"

# Export Total_Order_Summary as an Excel file
write.xlsx(Total_Order_Summary, excel_file, rowNames = FALSE)



### PLM BOM FILE#####################################################################


# Use file.choose() to open a file chooser dialog 
file_path <- file.choose()

# Read the Excel file into a data frame
plm_data <- read_excel(file_path)

# Inner join based on the "ID" column
merged_df <- inner_join(plm_data, Total_Order_Summary , by = "Style Number", "Color", relationship = "many-to-many")


# result <- merged_df %>%
#   select('Style Number', 'Color', 'RM Reference', 'Color Tracking RM Color', 'Consumption', '3XS', '2XS', 'XS','S','M', 'L', 'XL', '2XL')
# 
# result[6:13] <- 0
# 
# counter = 6
# for (i in 49:56) {
#   result[counter] <- merged_df[i] * merged_df$Consumption
#   print(i, counter)
#   #print(result[counter])
#   counter = counter + 1
# }
# 
# 
# for (i in 48:56) {
#   result <- merged_df %>%
#     mutate(merged_df[i] * Consumption)
# }
# 
# 
# excel_file <- "result.xlsx"
# 
# # Export Total_Order_Summary as an Excel file
# write.xlsx(result, excel_file, rowNames = FALSE)
# 
