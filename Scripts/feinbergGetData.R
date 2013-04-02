########################################################################
##
##  Feinberg Project
##
##  Data Collection Script
##
########################################################################

##somewhat rigid right now - not sure best approach on sql variations - could/should just be all tables
getdata <- function(username,pass,host,db){
  suppressPackageStartupMessages(require(RPostgreSQL))
  suppressPackageStartupMessages(require(sqldf)) #install.packages('sqldf')
  db <- dbConnect(PostgreSQL(), 
                  user = username, 
                  host = host,
                  dbname = db, 
                  password = pass) #dbListTables(db) 
  location <- dbGetQuery(db, 'SELECT * from "LocationProbe"')
  screen <- dbGetQuery(db, 'SELECT * from "ScreenProbe"')
  battery <- dbGetQuery(db, 'SELECT * from "BatteryProbe"')
  data <- merge(location,screen,all=TRUE)
  data <- merge(data,battery,all=TRUE)
  data <- data[order(data$timestamp),]
  return(data)
} #end getdata

getdistance <- function(data){
  #some prepping for distance formula
  data.distance <- data[!is.na(data$LATITUDE),]
  data.distance <- data.distance[,c("timestamp","LATITUDE","LONGITUDE","ACCURACY")] ###HARDCODE CAN CREATE PROBLEMS
  data.distance <- data.distance[order(data.distance$timestamp),]
}