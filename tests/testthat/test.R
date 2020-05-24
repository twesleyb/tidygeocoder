#!/usr/env/bin Rscript

# The censusxy package is designed to provide easy access to the U.S. Census
# Bureau Geocoding Tools: https://geocoding.geo.census.gov/geocoder/ in R.

### Motivation
# The Census Bureau Geocoding Tools allow for both unlimited free geocoding as 
# well as an added level of reproducibility compared to commercial geocoders. 
# Many geospatial workflows involve a large quantity of addresses, hence our 
# core focus is on batch geocoding.

### Responsible Use
# The U.S. Census Bureau makes their geocoding API available without any API key, 
# and this package allows for virtually unlimited batch geocoding. Please use this 
# package responsibly, as others will need use of this API for their research.

### Installation
install.packages("censusxy")
#devtools::install_github("slu-openGIS/censusxy")

## Test data.
data("stl_homicides")

### Parsing Addresses
# Dataframe or alike object should contain seperate columns for:
# NOTE: The postmastr package might be helpful if you need to get city/zip from
# street address: https://github.com/slu-openGIS/postmastr).
# * street address - required
# * city
# * state 
# * zipcode

### Batch Geocoding
homicide_sf <- cxy_geocode(stl_homicides, address = street_address, 
			   city = city, state = state, zip = postal_code, class = "sf")

# Note, however, that it returns only matched addresses, including those approximated by street length. If there are unmatched addresses, they will be dropped from the output. Use `class = "dataframe"` to return all addresses, including those that are unmatched.

# Output returned as an `sf` object can be previewed with a package like [`mapview`](https://cran.r-project.org/package=mapview):
# mapview::mapview(homicide_sf)

# With A For Loop
addresses <- c("20 N Grand Blvd, St. Louis MO 63103", "3700 Lindell Blvd, St. Louis, MO 63108")
geocodes <- lapply(addresses, cxy_oneline)
