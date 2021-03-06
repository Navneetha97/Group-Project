# Sasha's Script
# March 12th 2020
# Working on Question 3:
# We will look into which region is the worst offender for bird strikes. 
# We will convert the airport names into airport coordinates so that geospatial packages like ggmaps, maps, mapdata, sp, and ggplot will be able to process the data effectively.
# We will then colour code each state by bird strike quantity that has occurred within their borders, with each airport marked with circle size proportional to strike count. 
# To tie our questions together, we will use a second map where the regions are colour coded by the most common clade of bird to be struck in each area. 
# We will then overlay a map of the four major migration pathways of birds in North America (Atlantic, Mississippi, Central, and Pacific) on top of our bird strike frequency map.
# Around 40% of all migrating waterfowl use the Mississippi Flyway, so we hypothesize that bird strikes of waterfowl will be significantly higher along this route.

data<-read.csv("NEwDataset.csv", header=TRUE, stringsAsFactors = FALSE, row.names = "X")
head(data)
colnames(data)
dim(data)

# To address this question I've downloaded a Global Airport Database from https://www.partow.net/miscellaneous/airportdatabase/
# With this database I will be able to get the coordinates of each airport
airportdata<-read.table("GlobalAirportDatabase.txt", header= FALSE, sep=":",quote = "")
head(airportdata)
dim(airportdata)
colnames(airportdata)

# Set the column names as they're outlined on the website
columnnames<-c("ICAO Code","IATA Code","Airport Name","City/Town","Country","Latitude Degrees","Latitude Minutes","Latitude Seconds","Latitude Direction","Longitude Degrees","Longitude Minutes","Longitude Seconds","Longitude Direction","Altitude","Latitude","Longitude")
colnames(airportdata)<-columnnames
head(airportdata)

# Install libraries - do this one time
#install.packages("lubridate")
#install.packages("ggrepel")
#install.packages("tidyverse")
#install.packages("usmap")
#install.packages("maptools")
#install.packages("rgdal")
#install.packages("maps")
#install.packages("rworldmap")
#install.packages("magick")
#install.packages("rlang")

# Load libraries - do this every time
library(lubridate)
library(ggplot2)
library(dplyr)
library(data.table)
library(ggrepel)
library(tidyverse)
library(usmap)
library(maptools)
library(rgdal)
library(maps)
library(rworldmap)
library(magick)

# First going to make map highlighting the number of bird strikes by state
length(unique(data$State)) # concerning there are 63 states in here, that's too many
length(unique(usmap::us_map()$abbr)) # going to filter them based on the ones here
states<-c(unique(usmap::us_map()$abbr))
datas<-subset(data, data$State %in% states)
length(unique(datas$State))
dim(datas)
dim(data)
length(unique(datas$Airport.ID))

sum(datas$State==states[1])

# Find the count of strikes in each state
counts<-rep(NA,51)
for(i in 1:51){
  counts[i]<-sum(datas$State==states[i])
}

# Make a new dataset
statestrike<-data.frame(state=states, Strikes=counts)
head(statestrike)
summary(statestrike)
statestrike[statestrike$Strike==max(statestrike$Strikes),] 
# TX has the most strikes with 14854- but Texas is also a huge state (second largest after Alaska) so it may just have a lot of airports
statestrike[statestrike$Strike==min(statestrike$Strikes),] 
# DE has the least strikes with 166- but DE is also the second smallest state after Rhode Island- so it may not have very many airports

p<-plot_usmap(data = statestrike, values = "Strikes", color = "grey") + 
  scale_fill_continuous(low= "white", high= "darkslategray3",name = "Number of Bird Strikes", label = scales::comma) + 
  theme(legend.position = "right",
          axis.line=element_blank(),axis.text.x=element_blank(),
          axis.text.y=element_blank(),axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "transparent",colour = NA),
          plot.background = element_rect(fill = "transparent",colour = NA),
          panel.border=element_blank())
p
ggsave("Firstmap.png", p, bg = "transparent",width = 10,height =5,units = "in")
# Scale the bird strikes by number of airports in each state
# Some states have more airports than others, so may not be a fair comparison
head(datas)
length(datas$State)
test2<-c()
airportnum<-c() #will be number of airports in each state
for(i in 1:length(states)){
  test2<-datas[datas$State==states[i],c(6,7)]
  airportnum<-append(airportnum,length(unique(test2$Airport)))
}
statestrikean<-data.frame(state=states, Strikes=round(counts/airportnum))
head(statestrikean)
summary(statestrikean)
statestrikean[statestrikean$Strike==max(statestrikean$Strikes),] # DC has the most strikes with 1475
statestrikean[statestrikean$Strike==min(statestrikean$Strikes),] # WY has the least strikes with 11

p1<-plot_usmap(data = statestrikean, values = "Strikes", color = "grey") + 
  scale_fill_continuous(low= "white", high= "darkslategray3",name = "Number of Bird Strikes per Airport in each State", label = scales::comma) + 
  theme(legend.position = "right",
        axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        panel.border=element_blank())
p1
ggsave("Secondmap.png", p1, bg = "transparent",width = 10,height =5,units = "in")
# The whole map is very light because DC is so much higher than everything else, yet very small
# Need to show DC better
pp1<-plot_usmap(data = statestrikean, values = "Strikes", color = "grey", include=c("DC","VA","MD","WD")) + 
  scale_fill_continuous(low= "white", high= "darkslategray3",name = "Number of Bird Strikes per Airport in each State", label = scales::comma) + 
  theme(legend.position = "right",
        axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        panel.border=element_blank())
pp1
ggsave("Secondmap2.png", pp1, bg = "transparent",width = 10,height =5,units = "in")
# Add the longitude and latitude to each observation based off the airport
head(data)
head(data,10)
head(airportdata) # I think I need to use the ICAO code since it's four letters
# Tried the code below using the original airport data, but there's missing values
# Also realized it would incorporate other worldwide airports, and just looking at the US for now
# So going to use the previously made datas
longcor<-rep(NA,length(datas$Airport.ID))
latcor<-rep(NA,length(datas$Airport.ID))
latmis<-c()
longmis<-c()
for(i in 1:length(datas$Airport.ID)){
  if(length(airportdata[grep(datas$Airport.ID[i],airportdata$`ICAO Code`),]$Longitude)==0){
    longmis<-append(longmis,datas$Airport.ID[i])
    longcor[i]<-NA
  }else{
    longcor[i]<-airportdata[grep(datas$Airport.ID[i],airportdata$`ICAO Code`),]$Longitude
  }
  if(length(airportdata[grep(datas$Airport.ID[i],airportdata$`ICAO Code`),]$Latitude)==0){
    latcor[i]<-NA
    latmis<-append(latmis,datas$Airport.ID[i])
  }else{
    latcor[i]<-airportdata[grep(datas$Airport.ID[i],airportdata$`ICAO Code`),]$Latitude
  }
}

length(unique(latmis)) #1553 airports missing from dataset, but only 1914 to begin with
length(unique(longmis))
# So unfortunately this Global Airport database doesn't contain many of the US airports
# So I've downloaded a USA specific dataset which may be better

# Load new US airport data from https://data.humdata.org/dataset/ourairports-usa#
usair<-read.csv("us-airports.csv", header=TRUE, stringsAsFactors = FALSE)
head(usair)

# Remove first row
usair<-usair[-1,]
head(usair)
dim(usair)
colnames(usair)

# Try the loop again
longcor1<-rep(NA,length(datas$Airport.ID))
latcor1<-rep(NA,length(datas$Airport.ID))
latmis1<-c()
longmis1<-c()
for(i in 1:length(datas$Airport.ID)){
  if(length(usair[grep(datas$Airport.ID[i],usair$ident),]$longitude_deg)==0){
    longmis1<-append(longmis1,datas$Airport.ID[i])
    longcor1[i]<-NA
  }else{
    longcor1[i]<-usair[grep(datas$Airport.ID[i],usair$ident),]$longitude_deg
  }
  if(length(usair[grep(datas$Airport.ID[i],usair$ident),]$latitude_deg)==0){
    latcor1[i]<-NA
    latmis1<-append(latmis1,datas$Airport.ID[i])
  }else{
    latcor1[i]<-usair[grep(datas$Airport.ID[i],usair$ident),]$latitude_deg
  }
}

length(unique(latmis1)) #only missing 37 out of the 1914 airports in the US
length(unique(longmis1))

# Filter out missing airports
head(datas)
dim(datas)
misports<-c(unique(latmis1))
'%!in%' <- function(x,y)!('%in%'(x,y))
ndatas<-subset(datas,datas$Airport.ID %!in% misports)
dim(ndatas)

# Find the count of strikes in each state for the new filtered airport dataset
ncounts<-rep(NA,51)
for(i in 1:51){
  ncounts[i]<-sum(ndatas$State==states[i])
}

# Make a new dataset of the states and strikes
nstatestrike<-data.frame(state=states, Strikes=ncounts)
head(nstatestrike)

# Make a new dataset of the airports and strikes
length(unique(ndatas$Airport.ID))
usairports<-unique(ndatas$Airport.ID)
portstrikescounts<-rep(NA,length(unique(ndatas$Airport.ID)))
for(i in 1:length(unique(ndatas$Airport.ID))){
  portstrikescounts[i]<-sum(ndatas$Airport.ID==usairports[i])
}

airportstrikes<-data.frame(Airport=usairports, Strikes=portstrikescounts)
head(airportstrikes)

# Run loop with new airports and strikes dataset
nlongcor<-rep(NA,length(airportstrikes$Airport))
nlatcor<-rep(NA,length(airportstrikes$Airport))
nlatmis<-c()
nlongmis<-c()
for(i in 1:length(airportstrikes$Airport)){
  if(length(usair[grep(airportstrikes$Airport[i],usair$ident),]$longitude_deg)==0){
    nlongmis<-append(nlongmis,airportstrikes$Airport[i])
    nlongcor[i]<-NA
  }else{
    nlongcor[i]<-usair[grep(airportstrikes$Airport[i],usair$ident),]$longitude_deg
  }
  if(length(usair[grep(airportstrikes$Airport[i],usair$ident),]$latitude_deg)==0){
    nlatcor[i]<-NA
    nlatmis<-append(nlatmis,airportstrikes$Airport[i])
  }else{
    nlatcor[i]<-usair[grep(airportstrikes$Airport[i],usair$ident),]$latitude_deg
  }
}

length(unique(nlatmis)) #these are zero as they should be
length(unique(nlongmis))

# Add the coordinates to the new airport and strikes dataset
airportstrikes$Longitude<-nlongcor
airportstrikes$Latitude<-nlatcor
head(airportstrikes)
airportstrikes$Longitude<-as.numeric(airportstrikes$Longitude)
airportstrikes$Latitude<-as.numeric(airportstrikes$Latitude)
airportstrikes$Strikes<-as.numeric(airportstrikes$Strikes)
str(airportstrikes)

# Makea map using both datasets
p2<-plot_usmap(data = nstatestrike, values = "Strikes", color = "grey") + 
  scale_fill_continuous(low= "white", high= "darkslategray3",name = "Number of Bird Strikes per State", label = scales::comma) + 
  theme(legend.position = "right",
        axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        panel.border=element_blank())
p2

test_data <- data.frame(lon = as.numeric(nlongcor), lat = as.numeric(nlatcor), strike=portstrikescounts)

transformed_data <- usmap_transform(test_data)

dim(test_data)
dim(transformed_data)
head(test_data)
head(transformed_data) #strange that I loose two rows when I transform the data
tail(test_data)
tail(transformed_data) #missing the last five rows from test_data?

plot_usmap("states") + 
  geom_point(data = transformed_data, 
             aes(x = lon.1, y = lat.1, size = strike), 
             color = "red",
             alpha = 0.25)+
  labs(title = "US Bird Strikes per Airport",
       size = "Number of Strikes") +
  theme(legend.position = "right")

#Overlay the second map 
p3<-p2 + 
  geom_point(data = transformed_data, 
             aes(x = lon.1, y = lat.1, size = strike), 
             color = "tomato",
             alpha = 0.25)+
  labs(title = "US Bird Strikes per Airport",
       size = "Number of Strikes per Airport") +
  theme(legend.position = "right")
p3
ggsave("Thirdmap.png", p3, bg = "transparent",width = 12,height =6,units = "in")

# Make a world map
map('world', fill = TRUE, col = "grey")

prelim_plot <- ggplot(airportdata, aes(x = Longitude, y = Latitude)) +
    geom_point()
prelim_plot                

world <- getMap(resolution = "low")

with_world <- ggplot() +
    geom_polygon(data = world, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, colour = "black") + 
    geom_point(data = airportdata, 
               aes(x = Longitude, y = Latitude, colour="orange")) +
    coord_quickmap() +  
    theme_classic() +  
    xlab("Longitude") +
    ylab("Latitude") 
with_world

# Make a new dataset of global airports and strikes
head(data)
head(airportdata)
length(unique(data$Airport.ID))
globalairports<-unique(data$Airport.ID)
gloportstrikescounts<-rep(NA,length(unique(data$Airport.ID)))
for(i in 1:length(unique(data$Airport.ID))){
  gloportstrikescounts[i]<-sum(data$Airport.ID==globalairports[i])
}

globalairportstrikes<-data.frame(Airport=globalairports, Strikes=gloportstrikescounts)
head(globalairportstrikes)
dim(globalairportstrikes)
summary(globalairportstrikes)
globalairportstrikes[globalairportstrikes$Strike==max(globalairportstrikes$Strikes),] 
# Airport ZZZZ has the most strikes with 18570 which makes sense since according to wikipedia
# "ZZZZ is a special code which is used when no ICAO code exists for the airport. It is often used by helicopters not operating at an aerodrome."
globalairportstrikes[globalairportstrikes$Strike==min(globalairportstrikes$Strikes),] # There's 2147 airports all with only 1 recorded strike

# Subset global airport and strikes dataset by the airports included in the airportdata
nglobalairportstrikes<-subset(globalairportstrikes, globalairportstrikes$Airport %in% airportdata$`ICAO Code`)
dim(globalairportstrikes)
dim(nglobalairportstrikes) #639 global airports (missing a lot of those US airports probably)
summary(nglobalairportstrikes)
nglobalairportstrikes[nglobalairportstrikes$Strike==max(nglobalairportstrikes$Strikes),] 
# KDEN airport has the most strikes with 5434
dim(nglobalairportstrikes[nglobalairportstrikes$Strike==min(nglobalairportstrikes$Strikes),])
# 2223 airports all have only 1 recorded strike

longcoor<-rep(NA,length(nglobalairportstrikes$Airport))
latcoor<-rep(NA,length(nglobalairportstrikes$Airport))
latmiss<-c()
longmiss<-c()
for(i in 1:length(nglobalairportstrikes$Airport)){
  if(length(airportdata[grep(nglobalairportstrikes$Airport[i],airportdata$`ICAO Code`),]$Longitude)==0){
    longmiss<-append(longmiss,nglobalairportstrikes$Airport[i])
    longcoor[i]<-NA
  }else{
    longcoor[i]<-airportdata[grep(nglobalairportstrikes$Airport[i],airportdata$`ICAO Code`),]$Longitude
  }
  if(length(airportdata[grep(nglobalairportstrikes$Airport[i],airportdata$`ICAO Code`),]$Latitude)==0){
    latcoor[i]<-NA
    latmiss<-append(latmiss,nglobalairportstrikes$Airport[i])
  }else{
    latcoor[i]<-airportdata[grep(nglobalairportstrikes$Airport[i],airportdata$`ICAO Code`),]$Latitude
  }
}

length(unique(latmiss)) #zero as it should be
length(unique(data$Airport.ID)) #2228

# Add the coordinates to the new airport and strikes dataset
nglobalairportstrikes$Longitude<-as.numeric(longcoor)
nglobalairportstrikes$Latitude<-as.numeric(latcoor)
head(nglobalairportstrikes)
nglobalairportstrikes$Strikes<-as.numeric(nglobalairportstrikes$Strikes)
str(nglobalairportstrikes)

# Plot
map1 <- ggplot() +
  geom_polygon(data = world, 
               aes(x = long, y = lat, group = group),
               fill = "darkslategray3", colour = "white") + 
  geom_point(data = nglobalairportstrikes, 
             aes(x = Longitude, y = Latitude, size= Strikes),colour="tomato",alpha = 0.25) +
  labs(title = "Global Bird Strikes per Airport",
       size = "Number of Strikes per Airport")+
  coord_quickmap() +  
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),plot.background=element_blank())
map1
ggsave("Fourthmap.png", map1, bg = "transparent",width = 20,height =8,units = "in")
# I should combine the two data sets- the global and US airports so that overall more of the data is included in the worldwide map
head(nglobalairportstrikes)
dim(nglobalairportstrikes)
head(airportstrikes)
dim(airportstrikes)
allairportstrikes<-rbind(nglobalairportstrikes,airportstrikes)
dim(allairportstrikes)
length(unique(allairportstrikes$Airport))
# Need to remove all duplicate airports
abcairports<-allairportstrikes[order(allairportstrikes$Airport),] #let's us easily see the duplicates
uniqueallairports<-allairportstrikes[!duplicated(allairportstrikes$Airport),]
uniqueallairportss<-uniqueallairports[order(uniqueallairports$Airport),] #let's us easily check no more duplicates

dim(uniqueallairports)
summary(uniqueallairports)
uniqueallairports[uniqueallairports$Strike==max(uniqueallairports$Strikes),] 
# KDEN airport has the most strikes with 5434
dim(uniqueallairports[uniqueallairports$Strike==min(uniqueallairports$Strikes),])

# Now can remake the world map with way more points
map2 <- ggplot() +
  geom_polygon(data = world, 
               aes(x = long, y = lat, group = group),
               fill = "darkslategray3", colour = "white") + 
  geom_point(data = uniqueallairports, 
             aes(x = Longitude, y = Latitude, size= Strikes),colour="tomato",alpha = 0.25) +
  labs(title = "Global Bird Strikes per Airport",
       size = "Number of Strikes per Airport")+
  coord_quickmap() +  
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),plot.background=element_blank())
map2
ggsave("Fifthmap.png", map2, bg = "transparent",width = 20,height =8,units = "in")
# Now need to figure out how to overlay maps/ how to make a map of the migration pathways
# See if we can save the world map as transparent- could take the points and overlay them on the migration image
map3 <- ggplot() +
  geom_polygon(data = world, 
               aes(x = long, y = lat, group = group),
               fill = "darkslategray3", colour = "white") + 
  geom_point(data = uniqueallairports, 
             aes(x = Longitude, y = Latitude, size= Strikes),colour="tomato",alpha = 0.25) +
  labs(title = "Global Bird Strikes per Airport",
       size = "Number of Strikes per Airport")+
  coord_quickmap() +  
  theme(
    axis.line=element_blank(),axis.text.x=element_blank(),
    axis.text.y=element_blank(),axis.ticks=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "transparent",colour = NA),
    plot.background = element_rect(fill = "transparent",colour = NA),
    panel.border=element_blank()
  )
map3
ggsave("test.png", map3, bg = "transparent") 
# Awesome! That saved it transparent!

# Probably only want to save the points and border though- no fill
map4 <- ggplot() +
  geom_polygon(data = world, 
               aes(x = long, y = lat, group = group),
               fill = NA, colour = "grey") + 
  geom_point(data = uniqueallairports, 
             aes(x = Longitude, y = Latitude, size= Strikes),colour="tomato",alpha = 0.25) +
  labs(title = "Global Bird Strikes per Airport",
       size = "Number of Strikes per Airport")+
  coord_quickmap() +  
  theme(
    axis.line=element_blank(),axis.text.x=element_blank(),
    axis.text.y=element_blank(),axis.ticks=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "transparent",colour = NA),
    plot.background = element_rect(fill = "transparent",colour = NA),
    panel.border=element_blank()
  )
map4
ggsave("maptest.png", map4, bg = "transparent",width = 90,height =70,units = "cm") # needs to be pretty big so its not too crowded
ggsave("maptest2.png", map4, bg = "transparent",width = 30,height =23.3,units = "cm") # needs to be pretty big so its not too crowded

# Now it makes the most sense only look at North America and South America on the world map
# I think it may be easiest to just crop and blow up the original world map, rather than remake the map with only north and latin america

testmap <- image_read('maptest.png')
print(testmap)

testmap1<-image_crop(testmap, "4500x6000")
image_browse(testmap1)

# I downloaded a lot of bird migration diagrams- but finding a good one to overlay may be difficult to find the right one
# The issue is that the maps I've made are flat, whereas a lot of the maps for migration pathways are curved
# Try to overlay two worldmaps
worldwidepaths<-image_read('WordwideMigrationPaths.jpg')
print(worldwidepaths)
testmap2<-image_crop(testmap, "9950x5500")
image_browse(testmap2)
print(testmap2)
testmap22 <- image_scale(testmap2, "400")
print(testmap22)
trster<-image_composite(worldwidepaths, testmap2)
image_browse(trster)

# Makea map of states with just points, no alaska or hawaii too
# going to have to remake the entire first map/dataset without the Alaska and Hawaii airports
# First need to subset datas so that there's no alaskan or hawaiian airports
notwant<-c("AK","HI")
datas2<-subset(datas, datas$State %!in% notwant)
dim(datas2) #146336   by  19
dim(datas) # 150951  by   19

# Try the loop again
longcor12<-rep(NA,length(datas2$Airport.ID))
latcor12<-rep(NA,length(datas2$Airport.ID))
latmis12<-c()
longmis12<-c()
for(i in 1:length(datas2$Airport.ID)){
  if(length(usair[grep(datas2$Airport.ID[i],usair$ident),]$longitude_deg)==0){
    longmis12<-append(longmis12,datas2$Airport.ID[i])
    longcor12[i]<-NA
  }else{
    longcor12[i]<-usair[grep(datas2$Airport.ID[i],usair$ident),]$longitude_deg
  }
  if(length(usair[grep(datas2$Airport.ID[i],usair$ident),]$latitude_deg)==0){
    latcor12[i]<-NA
    latmis12<-append(latmis12,datas2$Airport.ID[i])
  }else{
    latcor12[i]<-usair[grep(datas2$Airport.ID[i],usair$ident),]$latitude_deg
  }
}

length(unique(latmis12)) #only missing 35 out of the 1914 airports in the US
length(unique(longmis12))

# Filter out missing airports
head(datas2)
dim(datas2)
misports2<-c(unique(latmis12))
ndatas2<-subset(datas2,datas2$Airport.ID %!in% misports2)
dim(ndatas2)

# Find the count of strikes in each state for the new filtered airport dataset
ncounts2<-rep(NA,49)
length(ncounts2)
states2<-states[states %!in% notwant]
length(states2)
for(i in 1:49){
  ncounts2[i]<-sum(ndatas2$State==states2[i])
}
length(ncounts2)

# Make a new dataset of the states and strikes
nstatestrike2<-data.frame(state=states2, Strikes=ncounts2)
head(nstatestrike2)

# Make a new dataset of the airports and strikes
length(unique(ndatas2$Airport.ID))
usairports2<-unique(ndatas2$Airport.ID)
portstrikescounts2<-rep(NA,length(unique(ndatas2$Airport.ID)))
for(i in 1:length(unique(ndatas2$Airport.ID))){
  portstrikescounts2[i]<-sum(ndatas2$Airport.ID==usairports2[i])
}

airportstrikes2<-data.frame(Airport=usairports2, Strikes=portstrikescounts2)
head(airportstrikes2)

# Run loop with new airports and strikes dataset
nlongcor2<-rep(NA,length(airportstrikes2$Airport))
nlatcor2<-rep(NA,length(airportstrikes2$Airport))
nlatmis2<-c()
nlongmis2<-c()
for(i in 1:length(airportstrikes2$Airport)){
  if(length(usair[grep(airportstrikes2$Airport[i],usair$ident),]$longitude_deg)==0){
    nlongmis2<-append(nlongmis2,airportstrikes2$Airport[i])
    nlongcor2[i]<-NA
  }else{
    nlongcor2[i]<-usair[grep(airportstrikes2$Airport[i],usair$ident),]$longitude_deg
  }
  if(length(usair[grep(airportstrikes2$Airport[i],usair$ident),]$latitude_deg)==0){
    nlatcor2[i]<-NA
    nlatmis2<-append(nlatmis2,airportstrikes2$Airport[i])
  }else{
    nlatcor2[i]<-usair[grep(airportstrikes2$Airport[i],usair$ident),]$latitude_deg
  }
}

length(unique(nlatmis2)) #these are zero as they should be
length(unique(nlongmis2))

# Add the coordinates to the new airport and strikes dataset
airportstrikes2$Longitude<-nlongcor2
airportstrikes2$Latitude<-nlatcor2
head(airportstrikes2)
airportstrikes2$Longitude<-as.numeric(airportstrikes2$Longitude)
airportstrikes2$Latitude<-as.numeric(airportstrikes2$Latitude)
airportstrikes2$Strikes<-as.numeric(airportstrikes2$Strikes)
str(airportstrikes2)

# Makea map using both datasets
ptest<-plot_usmap(data = nstatestrike2,include=states2, values = "Strikes", color = "grey") + 
  scale_fill_continuous(low= "white", high= "darkslategray3",name = "Number of Bird Strikes per State", label = scales::comma) + 
  theme(legend.position = "right",
        axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        panel.border=element_blank())
ptest

test_data2 <- data.frame(lon = as.numeric(nlongcor2), lat = as.numeric(nlatcor2), strike=portstrikescounts2)

transformed_data2 <- usmap_transform(test_data2)

dim(test_data2)
dim(transformed_data2)
head(test_data2)
head(transformed_data2) #strange that I loose two rows when I transform the data
tail(test_data2)
tail(transformed_data2) #missing the last five rows from test_data?

ptest<-plot_usmap(include=states2, color = NA, alpha=0.01) + 
  theme(legend.position = "right",
        axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        panel.border=element_blank())
ptest

#Overlay the second map 
ptester<-ptest + 
  geom_point(data = transformed_data2, 
             aes(x = lon.1, y = lat.1, size = strike), 
             color = "darkblue",
             alpha = 0.25)+
  labs(size = "Number of Strikes per Airport") +
  theme(legend.position = "right")
ptester
ggsave("Tmap.png", ptester, bg = "transparent",width = 12,height =6,units = "in")

statespaths<-image_read('Waterfowlflywaysmap.png')
print(statespaths)
tmap<-image_read('Tmap.png')
tmap1<-image_crop(tmap,"3000x1800+50")
print(image_scale(tmap,"700"))
image_browse(tmap1)
print(tmap)
tmap22 <- image_scale(tmap, "500")
print(tmap22)
trster<-image_composite(statespaths,image_crop(image_scale(tmap,"615"),"630x350+25"), offset = "+2+17")
image_write(trster, "Testmap.png")
