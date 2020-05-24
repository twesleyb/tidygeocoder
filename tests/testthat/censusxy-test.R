#!/usr/env/bin Rscript

renv::load(getrd())

# The censusxy package is designed to provide easy access to the U.S. Census
# Bureau Geocoding Tools: https://geocoding.geo.census.gov/geocoder/ in R.

# The Census Bureau Geocoding Tools allow for both unlimited free geocoding as 
# well as an added level of reproducibility compared to commercial geocoders. 
# Many geospatial workflows involve a large quantity of addresses, hence our 
# core focus is on batch geocoding.

# NOTE: The U.S. Census Bureau makes their geocoding API available without any API key, 
# and this package allows for virtually unlimited batch geocoding. Please use this 
# package responsibly, as others will need use of this API for their research.

# Installation
#install.packages("censusxy")
#devtools::install_github("slu-openGIS/censusxy")

# NOTE: Installation fails because of unmet units dependency.
# The 'sf' option in the central cxy_geocode function utilzes the
# 'sf' package, which in turn relies upon the units library.
# I've forked the repo and just commented out the offending line.
# Try installing my fork:
#devtools::install_github("twesleyb/census_xy")

# Load the test data.
library(censusxy)
data("stl_homicides")

# Parsing Addresses
# Dataframe or alike object should contain seperate columns for:
# NOTE: The postmastr package might be helpful if you need to get city/zip from
# street address: https://github.com/slu-openGIS/postmastr).
# * street address - required; the rest are optional.
# * city
# * state 
# * zipcode

# Batch Geocoding
homicide_sf <- cxy_geocode(stl_homicides, street = 'street_address', city = 'city', state = 'state', zip = 'postal_code')
