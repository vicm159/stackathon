library(tidyverse)
library(ggplot2)
library(DBI)
library(odbc)
library(caret)

DB <- 
  dbConnect(odbc(), "PostgreSQL victorfullstack")

housing <- 
  dbReadTable(DB, Id(schema = "stackathon", name ="housingclean")) 



