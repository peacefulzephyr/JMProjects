# Set working Directory to file location
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Load Libraries
library(data.table)
library(tidyverse)
library(rio)
library(lubridate)

# Load Data
input <- import("../Output/S&P history temp.dta") #%>% 
  #filter(Rating_Range_From30 %>% str_length() > 0)

# For each ISIN, create rows corresponding to each month (1st day of the month) FROM the first credit rating history date TO today 
panel_base <- setDT(input)[, .(
  Month = seq(startdate %>%  floor_date("month") , to = today(),  by = "month")
), by = ISIN] %>% 
  inner_join(., input, by = "ISIN") %>% 
  mutate(ThenRating = NA) %>%  # Create a indicator recording the rating at that month particularly, use NA as a placeholder
  relocate(ThenRating) # Move ThenRating to the first column

  # Remove "input" data to reduce RAM space
  rm(input)

# Update the ThenRating variable if time passes into the next credit rating time period  
for (i in 35:2) {
varnameFrom <- paste0("Rating_Range_From", i, sep = '')
varnameRating <- paste0("Rating", i, sep = '')

panel_base <- panel_base %>% 
  mutate(ThenRating = ifelse(Month > get(varnameFrom) ,get(varnameRating), ThenRating )) %>% 
  mutate(ThenRating = str_replace_all(ThenRating, '\n', ''))
} 

# Keep only a few selected variables
panel_builder <- panel_base[, c('ISIN','WSID', 'WSIDP', 'Month', 'ThenRating'), with = FALSE]


  # Remove "input" data to reduce RAM space
  rm(panel_base)

export(panel_builder, "../Output/S&P Panel Builder.csv")
