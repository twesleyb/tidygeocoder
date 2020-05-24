#!/usr/env/bin Rscript

# The censusxy package provides easy access to the U.S. Census Bureau's
# Geocoding Tools: https://geocoding.geo.census.gov/geocoder/ in R.
# These tools allow for unlimited, free geocoding.

# Installation
# install.packages("censusxy")
# devtools::install_github("slu-openGIS/censusxy")

# NOTE: Installation fails because of units dependency.
# The 'sf' option in the central cxy_geocode function utilzes the
# 'sf' package, which in turn relies upon the units library.
# I've forked the repo and just commented out the offending line.
# Try installing my fork:
#devtools::install_github("twesleyb/census_xy")

# Load renv.
renv::load(getrd())

# Load censusxy.
library(censusxy)

# Load the test data.
data(stl_homicides)

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
