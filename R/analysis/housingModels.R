library(tidyverse)
library(ggplot2)
library(DBI)
library(odbc)
library(caret)

DB <- 
  dbConnect(odbc(), "PostgreSQL victorfullstack")

housing <- 
  dbReadTable(DB, Id(schema = "stackathon", name ="housingclean"))

housingURL <- 
  dbReadTable(DB, Id(schema = "stackathon", name = "housingdata"))

housing$url <- housingURL$address

qplot(baths, soldPrice1/1000, data = housing, ylab = "price in thousands", main = "price and baths")
qplot(beds, soldPrice1/1000, data = housing, ylab = "price in thousands", main = "price and beds")
qplot(sqft, soldPrice1/1000, data = housing, ylap = "price in thousands", main = "price and sqft")

qplot(baths, zillowEstimate1/1000, data = housing, ylab = "price in thousands", main = "zillow estimate and baths")
qplot(beds, zillowEstimate1/1000, data = housing, ylab = "price in thousands", main = "zillow and beds")
qplot(sqft, zillowEstimate1/1000, data = housing, ylap = "price in thousands", main = "zillow and sqft")

train_data <- 
  housing %>% filter(OnMarket == 0) %>% 
  select(soldPrice1, beds, baths, sqft, city, zillowEstimate1)
                                               
lm_first <- 
  lm(soldPrice1 ~ beds + baths + sqft + I(sqrt(sqft)) + city, 
     data = train_data)

summary(lm_first)
plot(lm_first)

test_data <- 
  filter(housing, OnMarket == 1) %>% 
  select(beds, baths, sqft, city, address1, url, zillowEstimate1)

lm_predict <-
  predict(lm_first, test_data)

test_data$lm_predict <- lm_predict

dbWriteTable(DB, Id(schema = "stackathon", name = "lmPrediction"),
             test_data)




