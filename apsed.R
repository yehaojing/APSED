library(readxl)
library(sf)
library(tmap)
library(rmapshaper)

apsed_url <- "https://www.apsc.gov.au/sites/default/files/aps_employment_release_tables_-_30_june_2020.xlsx"
temp <- tempfile()
download.file(apsed_url, temp, mode = "wb")

apsed_df <- read_excel(path = temp, range = "Table 16!B4:T94")
names(apsed_df)[names(apsed_df) == "...1"] <- 'SA4'

#Get the data from the ABS:
#https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1270.0.55.001July%202016?OpenDocument
sa4_sf <- sf::st_read("SA4_2016_AUST/SA4_2016_AUST.shp")
sa4_sf_simp <- ms_simplify(sa4_sf, keep = 0.1)

apsed_sa4_merge <- merge(x = sa4_sf_simp, y = apsed_df, by.x = 'SA4_NAME16', by.y = "SA4")

tm_shape(subset(apsed_sa4_merge, grepl("Greater|Australian Capital Territory", apsed_sa4_merge$GCC_NAME16))) +
  tm_polygons("2020") +
  tm_layout(legend.position = c("left", "bottom")) +
  tm_facets("GCC_NAME16", free.scales = TRUE)

tm_shape(subset(apsed_sa4_merge, grepl("Rest of", apsed_sa4_merge$GCC_NAME16))) +
  tm_polygons("2020") +
  tm_layout(legend.position = c("left", "bottom")) +
  tm_facets("GCC_NAME16", free.scales = TRUE)
