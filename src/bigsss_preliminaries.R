###
### Claire Kelling
### BIGSSS Computational Social Science Summer School on Migration
###
### Created:      05/24/19
### Last Updated: 05/24/19
###

# Start clean
rm(list = ls())

# Packages
#use install.packages() if you do not have the package installed
library(maptools)
library(sp)
library(rgdal)
library(spatstat)

# Set working directory to bigsss_spatial_stats folder path
#     Note: directories have to include "/" not "\"
setwd("C:/Users/ckelling/Documents/Other/bigsss_spatial_stats")

###
### 1.) Load spatial polygon data data
###
bg_shp <- readShapeSpatial("data/block_group.shp",  proj4string=CRS("+proj=longlat +ellps=WGS84"))
plot(bg_shp)

###
### 2.) Load spatial points/events 
###
events <- read.csv("inputs/events.csv")

#sp_point <- cbind(events$LONGITUDE, events$LATITUDE) 
colnames(sp_point) <- c("LONG","LAT") 
proj <- CRS("+proj=longlat +datum=WGS84") 
data.sp <- SpatialPointsDataFrame(coords=sp_point, data=events, proj4string=proj) 
plot(data.sp, pch=16, cex=.5, axes=T)

# try overlaying the plots
plot(bg_shp)
plot(data.sp, add = T)

###
### 3.) Count events per areal unit
###
#Build a dataset with admin units, event counts, and population numbers
new_dataset <- as.data.frame(data.sp$bg_id)
names(new_dataset) <- c("bg_id")

#Generating new columns and setting them to NA
new_dataset$event_count <- NA

#Iterate over all units
for (i in 1:length(new_dataset[,1])){
  current_unit <- bg_shp[bg_shp$bg_id == new_dataset$bg_id[i],]
  new_dataset$event_count[i] <- length(data.sp[current_unit,])
}

# Add code for plotting events in ggplot

###
### 4.) Areal Unit modeling
###
#Preliminary test using Moran's I

#Create neighborhood matrix from shape file

#Create neighborhood matrix in different formats for different functions

#Plot neighborhood matrix

#Fit model using neighborhood matrix

###
### 5.) Point Process Modeling
###

## Preliminrary test using Ripley's K
#     Use the little helper function to painlessly generate a ppp object
arl_ppp <- to_ppp(data.sp, bg_shp)
#     Get Ripley's K plot with bootstrapped CIs
plot(envelope(arl_ppp,Kest),main="K for Arlington data")

# Plot ppp object
plot(arl_ppp)
# More visualizations
plot(density(arl_ppp))
persp(density(arl_ppp))

###
###
###

### TO DO 
### - put shp file in data directory for line 21, name block_group.shp
### - put events csv in data directory for line 25, name events.csv
### - add code for plotting overlay in ggplot, line 59


###################################
# Helper function to generate ppps#
###################################

to_ppp <- function(events,polygon){
  events  <- as(events,"SpatialPoints")
  events  <- as(events,"ppp")
  events  <- unique(events)
  polygon <- as(polygon,"SpatialPolygons")
  polygon <- as(polygon,"owin")
  ppp  <- ppp(events$x, events$y,window=polygon)
  return(ppp)
}