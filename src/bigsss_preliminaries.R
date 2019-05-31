###
### Claire Kelling
### BIGSSS Computational Social Science Summer School on Migration
###
### Created:      05/24/19
### Last Updated: 05/30/19
###

# Start clean
rm(list = ls())

# Packages
#use install.packages("package_name") if you do not have the package installed
library(maptools)
library(sp)
library(rgdal)
library(spatstat)
library(ggplot2)
library(dplyr)
library(spdep)
library(CARBayes)

# Set working directory to bigsss_spatial_stats folder path
#     Note: directories have to include "/" not "\"
setwd("C:/Users/ckell/Desktop/Google Drive/01_Penn State/Conference Work/BIGSSS CSSS 2019/spatial_stats_workshop")

###
### 1.) Load spatial polygon data data (Source: US Census)
###
load(file = "data/det_bg.Rdata")
det_bg <- det_bg_geog
rm(det_bg_geog)

plot(det_bg, main = "Block Groups in Detroit")


###
### 2.) Load spatial points/events (Source: Police Data Iniatiative)
###
load(file = "data/detroit_data.Rdata")
events <- detroit_data
rm(detroit_data)

#Only use a subset of the data, for simplicity (otherwise, takes a while to plot)
set.seed(2)
rand_ind <- runif(10000, 1, nrow(events))
events <- events[rand_ind,]

#converting to spatial points dataframe
sp_point <- cbind(events$Longitude, events$Latitude) 
colnames(sp_point) <- c("LONG","LAT") 
proj <- CRS("+proj=longlat +datum=WGS84") 
data.sp <- SpatialPointsDataFrame(coords=sp_point, data=events, proj4string=proj) 
plot(data.sp, pch=16, cex=.5, axes=T)

# try overlaying the plots
plot(det_bg)
plot(data.sp, col = "blue", pch=16, cex=0.6, add = T) #some points actually lie outside of Detroit

#clean up
rm(proj, sp_point, rand_ind)

###
### 3.) Count events per areal unit
###
#Build a dataset with event counts per block group
#Needs to have same projection as spatial points
det_bg <- spTransform(det_bg, proj4string(data.sp))

overlap_set <- over(data.sp, det_bg)
nrow(data.sp)
nrow(overlap_set) #it has classified each of the points in the dataset into a block group
sum(is.na(overlap_set$STATEFP)) #there are 466ish events that actually occur outside of city boundaries

detroit_df <- as.data.frame(data.sp)
det_dat_over <- cbind(detroit_df, overlap_set)
#det_dat_over <- det_dat_over[!is.na(over(domv_dat_detroit,det_bg)),]
det_dat_ov <- det_dat_over[!is.na(det_dat_over$GEOID),]

agg_dat <- plyr::count(det_dat_ov, c('GEOID'))
agg_dat$GEOID <- as.factor(agg_dat$GEOID)

#now I would like to create a plot that illustrates how many events are occuring per block group
num_per_bg <- as.numeric(agg_dat$freq)

#Now I will create the data structure that I need to create a plot
sp_f <- fortify(det_bg)
det_bg$id <- row.names(det_bg)
det_bg@data <- left_join(det_bg@data, agg_dat, by = (GEOID = "GEOID"))
sp_f <- left_join(sp_f, det_bg@data)

#make a color or grayscale plot to illustrate this
count_by_bg <- ggplot() + geom_polygon(data = sp_f, aes(long, lat, group = group, fill = freq)) + coord_equal() +
  labs(fill = "No. of \nEvents")+ geom_polygon(data=sp_f,aes(long,lat, group = group), 
                                               fill = NA, col = "black") +
  ggtitle("Number of Evemts per Block Group")+ scale_fill_gradient(low = "lightblue", high = "navyblue")
count_by_bg

rm(count_by_bg, sp_f, overlap_set, detroit_df, det_dat_over, det_dat_ov, agg_dat, num_per_bg, GEOID)

###
### 4.) Areal Unit modeling
###

length(which(is.na(det_bg@data$freq))) #8 block groups with no crime
det_bg$freq[which(is.na(det_bg@data$freq))] <- 0 #replace with 0, instead of NA

#Create neighborhood matrix from shape file
#Create neighborhood matrix in different formats for different functions
W.nb <- poly2nb(det_bg, row.names = rownames(det_bg@data)) 
W.list <- nb2listw(W.nb, style="B")
W.mat <- nb2mat(W.nb, style="B")
View(head(W.mat))

#Plot neighborhood matrix
coords <- coordinates(det_bg)
plot(det_bg, border = "gray",  main = "Neighorhood Matrix")
plot(W.nb, coords, pch = 1, cex = 0.6, col="blue", add = TRUE)

#Preliminary test using Moran's I
#non-spatial modeling (just linear model)
form <- freq ~ median_income + upemp_rate+total_pop+perc_male+med_age+herf_index
model <- lm(formula=form, data=det_bg@data)
resid.model <- residuals(model)
moran.mc(x=resid.model, listw=W.list, nsim=5000) 

#Fit model using neighborhood matrix
#rownames(W.mat) <- NULL #need this for test if matrix is symmetric
model.bym <- S.CARbym(formula=form, data=det_bg@data,
                           family="poisson", W=W.mat, burnin=20000, n.sample=150000, thin=10)
summary(model.bym)
model.bym$modelfit
model.bym$summary.results[,1:3]

rm(W.list, W.mat, W.nb, model, coords, form, resid.model, model.bym)

###
### 5.) Point Process Modeling
###

#Need to make smaller dataset for point process modeling
data.sp <- data.sp[runif(500, 1, length(data.sp)),]


## Preliminrary test using Ripley's K
# Transform our data into ppp object
bg_owin <- as.owin(det_bg)
xyzt <- as.matrix(coordinates(data.sp))
event_ppp <- as.ppp(xyzt, bg_owin) #some lie outside of the specified window

#Get Ripley's K plot with bootstrapped CIs
# simultaneous (takes a VERY long time)
#   sig level = (nrank/(1+nsim))
#k_sim <- envelope(event_ppp, fun = Kest, global = FALSE, nrank = 20, nsim = 800)

#F test using ECDF's
f_sim <- envelope(event_ppp, fun = Fest, global = FALSE, nrank = 20, nsim = 800)
plot(f_sim, main = "F function Envelope, Pointwise", ylab = "F function") 


# Plot ppp object
plot(event_ppp)
# More visualizations
plot(density(event_ppp))
persp(density(event_ppp))


