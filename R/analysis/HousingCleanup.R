library(tidyverse)
library(DBI)
library(odbc)
library(lubridate)

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
  # for some reason cannot get rid of beginning empty space so have to do this
  if(is.na(as.numeric(str_sub(beds, 1,1)))){
    beds <- str_sub(beds, 2,-1)
  }
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
  if(is.na(as.numeric(str_sub(baths,1,1)))){
    baths <- str_sub(baths,2,-1)
  }
  output$baths <- baths
  if(singlebath){
    baths_remove <- str_remove(baths_remove, "bath")
  }
  baths_remove <- str_remove(baths_remove, "baths")
  
  sqft_remove <- str_sub(baths_remove, str_locate(baths_remove, "sqft")[[1]],-1)
  sqft <- str_remove(baths_remove, sqft_remove)
  if(str_detect(row, "sqft") && is.na(sqft)){
    sqft <- str_remove(row, "sqft")
  }
  sqft <- str_remove_all(sqft, "\\,")
  if(is.na(as.numeric(str_sub(sqft, 1,1)))){
    sqft <- str_sub(sqft, 2,-1)
  }
  output$sqft <- sqft
  return(output)
}) 

housing <- 
  cbind(housing, homeDetails)
rm(homeDetails)

housing <- 
  housing %>% mutate(beds = as.numeric(beds), baths = as.numeric(baths),
                     sqft = as.numeric(sqft))

zillowEst <- 
  str_replace_all(housing$zillowEstimate, "[^1234567890]","")


housingClean <- 
  select(housing, zillowEstimate, OnMarket, soldPrice1, dateSold1, city, beds, baths, sqft,
         address1) %>%
  cbind(data_frame(zillowEstimate1 = zillowEst))

# easier way for regex and string manipulation
# housingClean <- 
#   mutate(housingClean, soldPrice = str_replace_all(soldPrice, "[^1234567890]",""),
#          dateSold = str_replace_all(dateSold, "[^0-9]","")) %>%
#   mutate(dateSold =  mdy(dateSold))

housingClean <- 
  mutate(housingClean, dateSold1 = mdy(dateSold1))

housingClean <- 
  housingClean %>% mutate(soldPrice1 = as.numeric(soldPrice1),
                     zillowEstimate1 = as.numeric(zillowEstimate1))

dbWriteTable(DB, Id(schema = "stackathon", name = "housingclean"), housingClean,
             overwrite = TRUE)


