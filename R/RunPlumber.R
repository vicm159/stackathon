r <- plumber::plumb("/Users/victormarta1/Documents/FS_LibraryRepo/Stackathon/webApp/R/plumber.R")
r$run(host="0.0.0.0", port=8081)