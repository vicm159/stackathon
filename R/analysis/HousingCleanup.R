library(tidyverse)
library(DBI)
library(odbc)

DB <- 
  dbConnect(odbc(), "PostgreSQL victorfullstack")

housing <- 
  dbReadTable(DB, Id(schema="stackathon", name="housingdata")) %>%
  as_tibble()

housing <- 
  housing %>% mutate(address1 = str_replace(address, "homedetails", "") %>%
                       str_sub(3, -1))

newAddress <- 
map_chr(housing$address1, function(row){
  str_sub(row, 1, str_locate(row, "/")[1])
}) %>%
  str_replace_all("/","") %>%
  str_replace_all("-"," ")

housing$address1 <- newAddress  
