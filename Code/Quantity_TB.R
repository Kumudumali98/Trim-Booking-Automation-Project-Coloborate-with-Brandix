
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
#merged_df <- full_join(plm_data, Total_Order_Summary , by = c("Style Number", "Style Color"), relationship = "one-to-one")

plm_data <- plm_data %>% mutate(Style_Color = toupper(plm_data$`Color`), .keep = "unused")

Total_Order_Summary <-  Total_Order_Summary %>% rename(Style_Color = Colors)


merged_df <- merge(x = plm_data, y = Total_Order_Summary, 
                   by = c("Style Number", "Style_Color"),
                   all.x = T)

result <- merged_df

result[12:19] <- 0

counter = 12
for (i in 12:19) {
  result[counter] <- ceiling(merged_df[i] * merged_df$Consumption * (1+merged_df$Wastage))
  counter = counter + 1
}

result <- result %>% rename(Style_Number = `Style Number`)
result <- result[result$Consumption != 0 | result$`RM Color` != "N/A",]


result <- result %>% 
  group_by(`RM Reference`, `RM Color`) %>%
  summarise(across(c(`3XS`, `2XS`, `XS`, `S`, `M`, `L`, `XL`, `2XL`), sum))


excel_file <- "result.xlsx"

# Export Total_Order_Summary as an Excel file
write.xlsx(result, excel_file, rowNames = FALSE)

####################Comparison############################################3

