# libraries
library(sf)
library(plyr)
library(tidyverse)
library(terra)


#### load mire map
# open geodatabase
#st_layers(dsn = "R:/Kladd/Myr_Norge/Myr_Norge.gdb")
#ANO.sp <- st_read("R:/Kladd/Myr_Norge/Myr_Norge.gdb",
#                    layer="ANO_Art")

# load tiff
myr <- terra::rast("R:/Kladd/Myr_Norge/MyrNorge.tif")
terra::plot(myr)

#### Import Norway map
nor <- st_read("P:/22202210_ecomap/Norway outline/outlineOfNorway_EPSG25833.shp")%>%
  st_as_sf() %>%
  st_transform(crs = st_crs(myr))

#myr <- crop(myr, nor, mask=TRUE)

#### load lime content map
lime <- st_read("P:/22202210_ecomap/explanatory variables/kalkinnhold/kalkinnhold_polygon.4326.geojson") %>%
  st_as_sf() %>%
  st_transform(crs = st_crs(myr))

# raterize lime to myr raster
#lime_ra <- rasterize(lime, myr, field="kode")
# does not work, probably because myr raster is too high resolution (10m)
# reduce raster resolution of myr to 50m
myr50 <- terra::aggregate(myr, fact = 5)

# raterize lime to myr raster
lime_ra <- rasterize(lime, myr50, field="verdi")

# set myr values for lime values < 154 (level f =154) to NA (keeping only NiN-levels f (slightly rich) and h (rich))
myr_limerich <- myr50
myr_limerich[lime_ra<154] <- NA
# set myr values with value 0 and myr-values where lime is NA (outside Norway) to NA
myr_limerich[is.na(lime_ra)] <- NA
myr_limerich[myr_limerich==0] <- NA
