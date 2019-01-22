library(plumber)
library(DBI)
library(odbc)
library(ggplot2)

DB <-
  dbConnect(odbc(), "PostgreSQL victorfullstack")

housing <- 
  dbGetQuery(DB, "select * from stackathon.\"lmPrediction\"")

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* Log some information about the incoming request
#* @filter logger
function(req){
  cat(as.character(Sys.time()), "-", 
      req$REQUEST_METHOD, req$PATH_INFO, "-", 
      req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR, "\n")
  plumber::forward()
}

#* Plot a histogram
#* @get /firstHouse
function(){
  sample_n(housing, 1)
}


#* @param city The second number to add
#* @get /graph/city
#* @png
function(){
  output <- 
    housing %>%
    ggplot(aes(x = lm_predict/1000, y = zillowEstimate1/1000)) +
    geom_point() + labs(x = "Linear Model Prediction in thousands", y = "Zillow Estimate in thousands") +
    labs(title = "Zillow vs my Prediction vs (eventually) your Guess")
  print(output)
}

