########################################################################
##
##  Feinberg Project
##
##  Main Formulas and Output
##
########################################################################

## If you want to source() a bunch of files, something like
## the following may be useful:
sourceDir <- function(path, trace = TRUE, ...) {
  for (nm in list.files(path, pattern = "\\.[RrSsQq]$")) {
    if(trace) cat(nm,":")           
    source(file.path(path, nm), ...)
    if(trace) cat("\n")
  }
}
sourceDir("~/FeinbergProject/Scripts")

#call to function for table aggregation
data <- getdata(username="jriley",
                pass="jriley", 
                host="165.124.171.126", 
                #db="f247b73e722c4d6355772e077b533209") #SAM - old
                #db="2da6265b1050aa0f2e791b152f72c7cc") #JOE - old
                db="9591f0ac97ca0d8d3565bd0443ce9dbd") #SAM - new
                #db="bcb4397dbe292359ee7a8f824ef14732") #JOE - new
data.distance <- getdistance(data)

#currently need home as global variable
home = c(41.966427,-87.665191) #SAM - old
#home = c(42.04465,-87.68459) #JOE - new

#calls both distance functions and binds to new dataframe
home.or.away <- as.data.frame(cbind(laggeddistance(home,data.distance[2:4]),homevaway(home,data.distance[2:4]),data.distance))
colnames(home.or.away)[1:2] <- c('distance','homeoraway')

##Interval Creation Loop
x=1
home.or.away$homeorawayID[1] = 1
for (i in 2:nrow(home.or.away)){
  if(home.or.away$homeoraway[i] != home.or.away$homeoraway[i-1]){
    x = x+1
  }
  home.or.away$homeorawayID[i] = x
}

##Bring new data in - joining on existing data
d2 <- merge(data,home.or.away,all=TRUE)

##Filling in the gaps - Following code will replace NAs with the previously known value
suppressPackageStartupMessages(require(zoo))
d2$homeoraway <- na.locf(d2$homeoraway,na.rm=FALSE)
d2$homeorawayID <- na.locf(d2$homeorawayID,na.rm=FALSE)
d3 <- as.data.frame(cbind(d2,unclass(as.POSIXlt(d2$timestamp,origin="1970-01-01"))))

detach("package:RPostgreSQL", unload=TRUE)
summary <- sqldf('select homeorawayid as interval,
                 homeoraway,
                 sum(distance) as totaldistancetravelled,
                 (max(timestamp)-min(timestamp)) as timespent,
                 cast(min(timestamp) as date) as mintime,
                 cast(max(timestamp) as date) as maxtime,
                 case when sum(plugged)>0 then 1 else 0 end as waspluggedin,
                 min(level) as minbattlevel,
                 max(level) as maxbattlevel,
                 sum(SCREEN_ACTIVE) as activescreencount
                 from d3 
                 group by homeorawayID, homeoraway')

summary$mintime <- as.POSIXlt(summary$mintime, origin="1970-01-01",tz="America/Chicago")
summary$maxtime <- as.POSIXlt(summary$maxtime, origin="1970-01-01",tz="America/Chicago")

sqldf("select * from d3 where eventDateTime like '%2013-04-02%'")