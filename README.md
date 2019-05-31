# Spatial Statistics Worshop
Through this repository, I've developed a workshop in Spatial Statistics for the BIGSSS Computational Social Science Summer School and Research Incubator. 

Files:
* BIGSSS_Spatial_Statistics_Workshop.pdf: This presentation gives a general overview of spatial statistics. There are brief explanations of areal unit and point process models, projections, geocoding, and spatial data analysis in R. This presentation was developed through a combination of the resources below, with parts drawn from my own research, Dr. Shaby's Introduction to Spatial Statistics lectures, and Dr. Schutte's introduction to Spatial Event Data Analysis.
* src/bigsss_preliminaries.R: This file demonstrates some basic spatial data analysis and spatial statistics models in R. We load spatial data (polygons and points) and demonstrate some basic areal unit and point process models. We use crime data and Detroit, Michigan as our examples in this code.
* data/: This folder contains all data used for the workshop.
  * data/det_bg.Rdata: This is the shape file for Detroit block groups (Source: US Census). 
  * data/detroit_data.Rdata: This is the event file for Detroit (Source: Police Data Initiative).


# References
* Julian Besag, Jeremy York, and Annie Mollié. Bayesian image restoration, with two applications in spatial statistics. Annals of the Institute of Statistical Mathematics, 43(1):1–20, 1991.
* Peter J Diggle. Statistical analysis of spatial and spatio-temporal point patterns. Chapman and Hall/CRC, 2013.
* Duncan Lee. CARBayes: An R package for Bayesian spatial modeling with conditional autoregressive priors. Journal of Statistical Software, 55(13):1–24, 2013.
* Shengde Liang, Bradley P Carlin, and Alan E Gelfand. Analysis of minnesota colon and rectum cancer point patterns with spatial and nonspatial covariate information. The annals of applied statistics, 3(3):943, 2008.
* Oliver Schabenberger and Carol A Gotway. Statistical methods for spatial data analysis. Chapman and Hall/CRC, 2017.
* Sebastian Schutte. Spatial event data analysis (in R!). BIGSSS CSS in Conflict,2018.
* Ben Shaby. Spatial models. Introduction to Spatial Statistics, 2017.
