####################
##
##  SLEEP PATTERNS
##
####################

library(sqldf)

d3$weekday <- weekdays(d3$eventDateTime)

####################
##
##  SLEEP PATTERNS
##
####################

library(sqldf)

#######THIS DOES NOT RUN AS IS.  JUST FOR WALK THROUGH PURPOSES
#######PREVIOUS CODE RUN TO GET THE [total data] table

# THIS CREATES PER HOUR PER DATE ACTIVITY
perhour <- sqldf("select year, mon, weekday, mday, hour, 
                  sum(SCREEN_ACTIVE) as activescreencount,
                  count(SCREEN_ACTIVE) as screenobs, 
                  (CASE WHEN sum(plugged) > 0 THEN 1 ELSE 0 END) as plugged
                 from d3
                 group by year, mon, weekday, mday, hour
                 order by year, mon, weekday, mday, hour")
perhour[is.na(perhour)==TRUE] = 0

# THIS CREATES TOTAL AGGREGATE PER HOUR ACTIVITY
perhourscreen <- sqldf("select hour, sum(activescreencount) as screens, 
                        sum(screenobs) as obscount,
                        sum(plugged) as plugged
                        from perhour
                        group by hour")

# NORMALIZE THE ACTIVITY DATA
pernormalized <- perhourscreen[,2:4]
pernormalized <- as.data.frame(scale(pernormalized))
colnames(pernormalized) <- c("snorm", "obsnorm", "pnorm")
perhourscreen2 <- cbind(perhourscreen,pernormalized) #bring back original data

##########GOING TO WRITE A QUICK LOOP TO CHECK FOR THE THREE PERIOD LOW ACTIVITY########
i=1
minimum=1
for(i in 1:nrow(perhourscreen2)){
  minimum[i] <- if(perhourscreen2$snorm[i]<0 & 
                   perhourscreen2$snorm[i+1]<0 & 
                   perhourscreen2$snorm[i+2]<0
                   )
                   {TRUE}
                else if(i==23 & 
                        perhourscreen2$snorm[i]<0 & 
                        perhourscreen2$snorm[24]<0 & 
                        perhourscreen2$snorm[1]<0
                        )
                        {TRUE}
                else if(i==24 & 
                        perhourscreen2$snorm[i]<0 & 
                        perhourscreen2$snorm[1]<0 & 
                        perhourscreen2$snorm[2]<0
                        )
                        {TRUE}
                else {FALSE}
                          
} #end loop
# TWO EXCEPTIONS WHERE THIS DOES NOT WORK - at hour 22 and hour 23
# OUTPUT IS VECTOR of 1 or 0

candidates <- cbind(perhourscreen2,minimum)
sleepStart <- min(candidates$hour[candidates$minimum==1]) #get earliest
###ADJUSTMENT TO 12 hours prior [only care about hour not date yet]
newDayHour <- if(sleepStart<12){sleepStart+12}else{sleepStart-12}

timeTest <- as.data.frame(perhourscreen$hour)
colnames(timeTest) <- c('hour')
timeTest$newDayHour <- ifelse(timeTest$hour==newDayHour,0,"")

#####NEED TO FINISH COUNTER AND FIGURE OUT HOW THE DAYS START
