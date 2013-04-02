########################################################################
##
##  Feinberg Project
##
##  Home vs. Away Script
##
########################################################################

#calculates Haversine distance between set of lat/long points
haversine = function(lat1, long1, lat2, long2) {
  rad = 6371
  diff.lat = pi*(lat2-lat1)/180
  diff.long = pi*(long2-long1)/180
  a = sin(diff.lat/2)^2 + cos(pi*lat1/180)*cos(pi*lat2/180)*(sin(diff.long/2)^2)
  c = 2*atan2(sqrt(a), sqrt(1 - a))
  d = rad*c
  #returns distance in meters
  return(d*1000)
}

homevaway = function(home,data){
  #calculate whether phone is within accuracy range of home
  #input home=home coordinates, lat=vector of latitudes, long=vector of longitudes, accuracy=vector of accuracy of measurements from phone
  ##utilize input and haversine to calc distance
  data.distance$atHOME = ifelse(((haversine(home[1],
                                            home[2],
                                            data.distance[,2],
                                            data.distance[,3]) - data.distance[,4]) > 0),0,1)
  return(data.distance$atHOME)
}  

##this gives the lagged distance between row x and x-1
laggeddistance = function(home, data) {
  at.home = rep(0,nrow(data))
  for (i in 2:nrow(data)) {
    at.home[i] = (haversine(data[i-1,1],data[i-1,2],data[i,1],data[i,2]))
  }
  return(at.home)
}