library(tidyverse)
library(ggplot2)
library(DBI)
library(odbc)
library(caret)

DB <- 
  dbConnect(odbc(), "PostgreSQL victorfullstack")

housing <- 
  dbReadTable(DB, Id(schema = "stackathon", name ="housingclean")) 

qplot(baths, soldPrice1/1000, data = housing, ylab = "price in thousands", main = "price and baths")
qplot(beds, soldPrice1/1000, data = housing, ylab = "price in thousands", main = "price and beds")
qplot(sqft, soldPrice1/1000, data = housing, ylap = "price in thousands", main = "price and sqft")

qplot(baths, zillowEstimate1/1000, data = housing, ylab = "price in thousands", main = "zillow estimate and baths")
qplot(beds, zillowEstimate1/1000, data = housing, ylab = "price in thousands", main = "zillow and beds")
qplot(sqft, zillowEstimate1/1000, data = housing, ylap = "price in thousands", main = "zillow and sqft")

lm_first <- 
  lm(soldPrice1 ~ beds + baths + sqft + I(sqrt(sqft)) + city, data = housing)

summary(lm_first)
plot(lm_first)

test <- 
  filter(housing, OnMarket == 1) %>% 
  select(beds, baths, sqft, city)

lm_predict <-
  predict(lm_first, test)

ggplot(filter(housing, OnMarket == 1), aes(x = zillowEstimate1, y = lm_predict)) +
  geom_point()

ggplot(filter(housing, OnMarket == 1), aes(x = 1:446, y = zillowEstimate1)) +
  geom_point() +
  geom_point(aes(y = lm_predict), colour = "red")





