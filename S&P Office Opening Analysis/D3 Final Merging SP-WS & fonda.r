# Set working Directory to file location
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Load Libraries
library(data.table)
library(tidyverse)
library(rio)
library(lubridate)
library(countrycode)

# Load S&P office Data
opening <- import("../Data/sp_office.dta") %>% 
  mutate(CountryCode = countrycode(sourcevar = headquarters, origin = "country.name", destination = "iso2c") 
           ) %>% 
  rename(SP_Open = sp_year) %>% 
  select(SP_Open, CountryCode)

# Clean funda Data & Rename
funda <- import("../Data/wrds_worldscope_funda.dta")  %>% 
  rename(ISIN = item6008,
         WSID = item6035,
         WSIDP = item6105, 
         FYend = item5350) %>% 
  mutate(CountryCode = substr(ISIN, 1,2) )

# Merge founda & S&P office opening Dates
fundaopen <- left_join(funda, opening, by = 'CountryCode') %>% 
  mutate(PostFYdate3m = floor_date(as.Date(FYend) %m+% months(3), "month" ) ,
         PostFYdate6m = floor_date(as.Date(FYend) %m+% months(6), "month" ) ,
         PostFYdate12m = floor_date(as.Date(FYend) %m+% months(12), "month" )
         ) %>% 
  mutate(SPopenbyFYend = as.numeric(year(as.Date(FYend)) > as.numeric(SP_Open)) )

rm(funda, opening)

# Load Panel Builder
panel_builder <- import("../Output/S&P Panel Builder.csv") %>% 
  mutate(Month = as.Date(Month)) %>% 
  mutate(ThenRating = ifelse(ThenRating %>%  str_detect('NR') , '', ThenRating) 
  )

# Form Fonda panel data by merging fonda-opendates & Panel builder
full_panel <- left_join(fundaopen, panel_builder, by= c("WSIDP" = "WSIDP", "PostFYdate3m" = "Month") ) %>% 
  rename(rating3mafterFYend = ThenRating) %>% 
  left_join(panel_builder, by= c("WSIDP" = "WSIDP", "PostFYdate6m" = "Month") ) %>% 
  rename(rating6mafterFYend = ThenRating) %>% 
  left_join(panel_builder, by= c("WSIDP" = "WSIDP", "PostFYdate12m" = "Month") ) %>% 
  rename(rating12mafterFYend = ThenRating) %>% 
  rename(ISIN = ISIN.x,
         WSID = WSID.x
         )

rm(funda, fundaopen, opening, panel_builder)

conversion <- import("../Data/Rating Numeric.xlsx") 

matched <- full_panel %>% 
  filter(!is.na(rating3mafterFYend) | !is.na(rating6mafterFYend) | !is.na(rating12mafterFYend)) %>% 
  filter( rating3mafterFYend != '' | rating3mafterFYend != '' | rating3mafterFYend != '') %>% 
  left_join(conversion, by = c('rating3mafterFYend' = 'Rating')) %>% 
  rename(rating3mafterFYend_num = NumericRating) %>% 
  left_join(conversion, by = c('rating6mafterFYend' = 'Rating')) %>% 
  rename(rating6mafterFYend_num = NumericRating) %>% 
  left_join(conversion, by = c('rating12mafterFYend' = 'Rating')) %>% 
  rename(rating12mafterFYend_num = NumericRating) %>% 
  .[,c(1:42, 47, 57:59)] %>% 
  mutate(FY = year(FYend))

rm(full_panel, conversion)

export(matched, '../Output/SP-WS-fonda.dta')