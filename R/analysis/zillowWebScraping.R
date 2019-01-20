library(tidyverse)
library(rvest)

getSinglePageURL <- 
  function(webpage){
    sloSold <- read_html(webpage)
    attrs <- 
      sloSold %>%
      html_nodes(".photo-cards") %>%
      html_nodes("li") %>%
      html_node("a") %>%
      html_attrs()
    output <- data_frame()
    for(i in 1:length(attrs)){
      output <- rbind(output, data_frame(url=attrs[[i]]["href"]))
    }
    return(output)
  }

# sold homes -----------------------

test <- 
  getSinglePageURL("https://www.zillow.com/homes/recently_sold/San-Luis-Obispo-County-CA/3261_rid/globalrelevanceex_sort/36.723475,-118.644105,33.945638,-122.181702_rect/7_zm/")

url_address <- data_frame()
for(i in 3:20){
  test <- 
    getSinglePageURL(str_c(
      "https://www.zillow.com/homes/recently_sold/San-Luis-Obispo-County-CA/3261_rid/globalrelevanceex_sort/36.723475,-118.644105,33.945638,-122.181702_rect/7_zm/",
      i,"_p/"
    ))
  test <- 
    test %>% filter(!is.na(url))
  url_address <- 
    rbind(url_address, test)
}

soldHomes <- data_frame()
for(i in 258:450){
  Sys.sleep(2)
  singlePage <- 
    read_html(str_c(
      "https://www.zillow.com",url_address$url[i]
    ))
  sold_price <- 
    singlePage %>% html_node(".home-details-price-area") %>%
    html_node(".status") %>% html_text
  
  date_sold <- 
    singlePage %>% html_node(".home-details-price-area") %>%
    html_node(".date-sold") %>% html_text
  
  zillow_estimate <- 
    singlePage %>% html_node(".home-details-price-area") %>%
    html_node('.zestimate') %>%
    html_text
  
  home_details <- 
    singlePage %>% html_node(".home-details-home-summary h3") %>%
    html_text
  
  soldHomes <- rbind(soldHomes, 
                     data_frame(address = url_address$url[i],
                                soldPrice = sold_price,
                                dateSold = date_sold,
                                zillowEstimate = zillow_estimate,
                                homeDetails = home_details))
}




# R selenemium ----------
#rD <- rsDriver(port=8080L)
# remDr <- rD[["client"]]
# remDr$navigate("https://www.zillow.com/homedetails/2600-Nutmeg-Ave-Morro-Bay-CA-93442/15443369_zpid/")
# 
# elem <- 
#   remDr$findElement(using ='id', 'price-and-tax-history')
# elem$click()
#remDr$close()
# rD[["server"]]$stop()
# ------------

# Currently on Market -----
webpage <- "https://www.zillow.com/homes/for_sale/San-Luis-Obispo-County-CA/3261_rid/globalrelevanceex_sort/36.723475,-118.644105,33.945638,-122.181702_rect/7_zm/0_mmm/"

onMarketUrl <- 
  getSinglePageURL(webpage)
# gets houses on market url

for(i in 2:20){
  test <- 
    getSinglePageURL(str_c(
      "https://www.zillow.com/homes/recently_sold/San-Luis-Obispo-County-CA/3261_rid/globalrelevanceex_sort/36.723475,-118.644105,33.945638,-122.181702_rect/7_zm/",
      i,"_p/0_mmm/"
    ))
  test <- 
    test %>% filter(!is.na(url))
  onMarketUrl <- 
    rbind(onMarketUrl, test)
}

onMarketHomes <- data_frame()
for(i in 308:450){
  Sys.sleep(2)
  singlePage <- 
    read_html(str_c(
      "https://www.zillow.com",onMarketUrl$url[i]
    ))
  current_price <- 
    singlePage %>% html_node(".home-details-pricing-floater") %>% 
    html_node(".price") %>% 
    html_text
  
  zillow_estimate <- 
    singlePage %>% html_node(".home-details-price-area") %>%
    html_node('.zestimate') %>%
    html_text
  
  home_details <- 
    singlePage %>% html_node(".home-details-home-summary h3") %>%
    html_text
  
  onMarketHomes <- rbind(onMarketHomes, 
                     data_frame(address = onMarketUrl$url[i],
                                zillowEstimate = zillow_estimate,
                                homeDetails = home_details))
}

soldHomes$OnMarket <- 0

fullStackDB <- dbConnect(odbc::odbc(), "PostgreSQL victorfullstack")

odbc::dbWriteTable(fullStackDB, 
             DBI::Id(schema="stackathon",name="housingdata"), as.data.frame(soldHomes),
             append = TRUE)

totalHomes <- 
  dbGetQuery(fullStackDB, "select * from stackathon.housingdata")





