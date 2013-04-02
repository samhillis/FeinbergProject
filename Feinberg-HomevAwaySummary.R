require(RPostgreSQL)
require(zoo) #install.packages('zoo')
require(sqldf) #install.packages('sqldf')

# #these must be quoted strings
# username =  'xxxxx'
# pass = 'xxxxx' 
# 
# ##somewhat rigid right now - not sure best approach on sql variations - could/should just be all tables
# getdata <- function(username,password){
#   db <- dbConnect(PostgreSQL(), 
#                   user = username, 
#                   host = "165.124.171.126",
#                   dbname = "f247b73e722c4d6355772e077b533209", 
#                   password = pass) #dbListTables(db) 
#   #dbWriteTable(db,#tablename,#dataframe)
#   light <- dbGetQuery(db, 'SELECT * from "LightProbe"')
#   location <- dbGetQuery(db, 'SELECT * from "LocationProbe"')
#   screen <- dbGetQuery(db, 'SELECT * from "ScreenProbe"')
#   battery <- dbGetQuery(db, 'SELECT * from "BatteryProbe"')
#   data <- merge(light,location,all=TRUE)
#   data <- merge(data,screen,all=TRUE)
#   data <- merge(data,battery,all=TRUE)
#   data <- data[order(data$timestamp),]
#   return(data)
# }
# #call to function for table aggregation
# data <- getdata(username,pass)
# 
# #need home as global variable
# home = c(41.966427,-87.665191)
# 
# #some prepping for distance formula
# data.distance <- data[!is.na(data$LATITUDE),]
# names(data.distance)
# data.distance <- data.distance[,c(2,17,18,14)] ###HARDCODE CAN CREATE PROBLEMS
# data.distance <- data.distance[order(data.distance$timestamp),]

# #calculates Haversine distance between set of lat/long points
# haversine = function(lat1, long1, lat2, long2) {
#   rad = 6371
#   diff.lat = pi*(lat2-lat1)/180
#   diff.long = pi*(long2-long1)/180
#   a = sin(diff.lat/2)^2 + cos(pi*lat1/180)*cos(pi*lat2/180)*(sin(diff.long/2)^2)
#   c = 2*atan2(sqrt(a), sqrt(1 - a))
#   d = rad*c
#   #returns distance in meters
#   return(d*1000)
# }
# 
# homevaway = function(home,data){
#   #calculate whether phone is within accuracy range of home
#   #input home=home coordinates, lat=vector of latitudes, long=vector of longitudes, accuracy=vector of accuracy of measurements from phone
#   ##utilize input and haversine to calc distance
#   data.distance$atHOME = ifelse(((haversine(home[1],
#                                             home[2],
#                                             data.distance[,2],
#                                             data.distance[,3]) - data.distance[,4]) > 0),0,1)
#   return(data.distance$atHOME)
# }  
# 
# ##this gives the lagged distance between row x and x-1
# laggeddistance = function(home, data) {
#   at.home = rep(0,nrow(data))
#   for (i in 2:nrow(data)) {
#     at.home[i] = (haversine(data[i-1,1],data[i-1,2],data[i,1],data[i,2]))
#   }
#   return(at.home)
# }
# 
# #calls both distance functions and binds to new dataframe
# home.or.away <- as.data.frame(cbind(laggeddistance(home,data.distance[2:4]),homevaway(home,data.distance[2:4]),data.distance))
# colnames(home.or.away)[1:2] <- c('distance','homeoraway')
# 
# ##Interval Creation Loop
# x=1
# home.or.away$homeorawayID[1] = 1
# for (i in 2:nrow(home.or.away)){
#   if(home.or.away$homeoraway[i] != home.or.away$homeoraway[i-1]){
#     x = x+1
#   }
#   home.or.away$homeorawayID[i] = x
# }
# ##Bring new data in - joining on existing data
# d2 <- merge(data,home.or.away,all=TRUE)
# 
# ##Filling in the gaps - Following code will replace NAs with the previously known value
# d2$homeoraway <- na.locf(d2$homeoraway,na.rm=FALSE)
# d2$homeorawayID <- na.locf(d2$homeorawayID,na.rm=FALSE)

##Finally creating some summary table
##RPostgresQL needs to be detached first for sqldf to work - weird but package side quirk
detach("package:RPostgreSQL", unload=TRUE)
summary <- sqldf("select homeorawayid as interval,
                 homeoraway,
                 sum(distance) as totaldistancetravelled,
                 (max(timestamp)-min(timestamp)) as timespent,
                 cast(min(timestamp) as date) as mintime,
                 cast(max(timestamp) as date) as maxtime,
                 sum(plugged) as pluggedincount,
                 case when sum(plugged) > 0 then 1 else 0 end as waspluggedin,
                 min(level) as minbattlevel,
                 max(level) as maxbattlevel,
                 avg(level) as avgbattlevel,
                 sum(SCREEN_ACTIVE) as activescreencount
                 from d2 
                 group by homeorawayID, homeoraway")

summary$mintime <- as.POSIXlt(summary$mintime, origin="1970-01-01")
summary$maxtime <- as.POSIXlt(summary$maxtime, origin="1970-01-01")
View(summary)
