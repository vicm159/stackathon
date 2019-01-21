library(tidyverse)
library(DBI)
library(odbc)

DB <- 
  dbConnect(odbc(), "PostgreSQL victorfullstack")

housing <- 
  dbReadTable(DB, Id(schema="stackathon", name="housingdata")) %>%
  as_tibble()

# changing address url to standard address
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
rm(newAddress)

housing$address1 <- str_to_lower(housing$address1)

housing <- 
housing %>% mutate(city = case_when(
  str_detect(address1, "arroyo grande") ~ "arroyo grande" ,
  str_detect(address1, "paso robles") ~ "paso robles",
  str_detect(address1, "san luis obispo") ~ "san luis obispo",
  str_detect(address1, "cambria") ~ "cambria",
  str_detect(address1, "atascadero") ~ "atascadero",
  str_detect(address1, "santa margarita") ~ "santa margarita",
  str_detect(address1, "pismo beach") ~ "pismo beach",
  str_detect(address1, "nipomo") ~ "nipomo",
  str_detect(address1, "morro bay") ~ "morro bay",
  str_detect(address1, "avila beach ") ~ "avila beach",
  str_detect(address1, "san miguel ca") ~ "san miguel",
  str_detect(address1, "los osos ca") ~ "los osos",
  str_detect(address1, "grover beach ca") ~ "grover beach",
  str_detect(address1, "cayucos ca") ~ "cayucos",
  str_detect(address1, "oceano ca") ~ "oceano",
  str_detect(address1, "san simeon ca") ~ "san simeon",
  str_detect(address1, "templeton ca") ~ "templeton",
  str_detect(address1, "shell beach ca") ~ "shell beach",
  str_detect(address1, "bradley ca") ~ "bradley",
  str_detect(address1, "heritage ranch ca") ~ "heritage ranch",
  str_detect(address1, "shandon") ~ "shandon"
  )
  )

housing <- 
housing %>% mutate(soldPrice1 = str_replace(soldPrice," Sold:","")) %>%
  mutate(soldPrice1 = str_replace(soldPrice1, "\\$","") %>% str_replace_all(",","")) 

housing <- 
housing %>% mutate(dateSold1 = str_replace(dateSold, "Sold on ",""))

homeDetails <- 
map_dfr(housing$homeDetails, function(row){
  output <- data_frame(beds = "", baths = "", sqft ="")
  singlebath <- FALSE
  singlebed <- FALSE
  beds_remove <- str_sub(row, str_locate(row, "beds")[[1]],-1)
  if(is.na(beds_remove)){
    beds_remove <- str_sub(row, str_locate(row, "bed")[[1]],-1)
    singlebed <- TRUE
  }
  beds <- str_remove(row, beds_remove) %>% str_remove_all(" ")
  output$beds <- beds
  if(singlebed){
    beds_remove <- str_remove(beds_remove, "bed")
  }
  beds_remove <- str_remove(beds_remove, "beds")
  
  baths_remove <- str_sub(beds_remove, str_locate(beds_remove, "baths")[[1]],-1)
  if(is.na(baths_remove)){
    baths_remove <- str_sub(beds_remove, str_locate(beds_remove, "bath")[[1]],-1)
    singlebath <- TRUE
  }
  baths <- str_remove(beds_remove, baths_remove)
  output$baths <- baths
  if(singlebath){
    baths_remove <- str_remove(baths_remove, "bath")
  }
  baths_remove <- str_remove(baths_remove, "baths")
  
  sqft_remove <- str_sub(baths_remove, str_locate(baths_remove, "sqft")[[1]],-1)
  sqft <- str_remove(baths_remove, sqft_remove)
  output$sqft <- sqft
  return(output)
}) 

cbind(homeDetails, housing$homeDetails) %>% View




