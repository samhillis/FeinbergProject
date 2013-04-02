d3$weekday <- weekdays(d3$eventDateTime)
perhour <- sqldf("select year, mon, weekday, mday, hour, 
sum(SCREEN_ACTIVE) as activescreencount,
count(SCREEN_ACTIVE) as screenobs, 
(CASE WHEN sum(plugged) > 0 THEN 1 ELSE 0 END) as plugged
                 from d3
                 group by year, mon, weekday, mday, hour
                 order by year, mon, weekday, mday, hour")
perhour[is.na(perhour)==TRUE] = 0
perhourscreen <- sqldf("select weekday, hour, sum(activescreencount) as screens, 
                        sum(screenobs) as obscount,
                        sum(plugged) as plugged
                        from perhour
                        group by weekday, hour")
perhourt <- t(perhourscreen)
barplot(perhourt[3:4,],
        names = perhourt[1,],
        ylab = 'Count',
        xlab = 'Hour',
        main = 'Total Screen Actives and Observations')

latenight <- sqldf("select year, mon, mday, sum(SCREEN_ACTIVE) as latenightactivity
      from d3
      WHERE hour between 0 and 7
      group by year, mon, mday
      order by year, mon, mday")
latenight[is.na(latenight)==TRUE] = 0
latenightt <- t(latenight[,4])
names <- paste(latenight$mon+1,'/',latenight$mday)
barplot(latenightt,
        names = names,
        ylab = 'Count',
        xlab = 'Month / Day',
        main = '1AM to 7AM Screen Actives')
