#!/usr/bin/env Rscript

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

# Parsing Addresses
# Dataframe or alike object should contain seperate columns for:
# NOTE: The postmastr package might be helpful if you need to get city/zip from
# street address: https://github.com/slu-openGIS/postmastr).
# * street address - required; the rest are optional.
# * city
# * state 
# * zipcode

#--------------------------------------------------------------------
# Load renv.
renv::load(getrd())

# Other imports:
suppressPackageStartupMessages({
	library(dplyr)
	library(censusxy)
	library(microbenchmark)
})

# Load the test data from the censusxy package.
data(stl_homicides)
dt <- stl_homicides

#--------------------------------------------------------------------
## Geocode a single address.

# Add column with complete addresses.
dt$address <- paste(dt$street_address,dt$city,
		    dt$state,dt$postal_code,sep=" ")

# Get a random address.
set.seed(as.numeric(Sys.time()))
address <- dt %>% filter(address == sample(address,1)) %>% 
	select(street_address,city,state,postal_code)
address <- setNames(unlist(address),nm=c("street","city","state","zip"))
addr0 <- as.list(address[attr(na.omit(address),"names")])
message(paste("\nGeocoding a single address:", 
	      paste(unlist(addr0), collapse=" ")))

# Geocode with cxy_single:
geocode <- function(addr) { suppressWarnings(do.call(cxy_single, addr)) } 
res0 <- geocode(addr0)
message("\nCensusxy coordinates:")
res0 %>% select(coordinates.y, coordinates.x) %>% 
	knitr::kable(col.names=c("lat","long"))

# Zip code is missing from the test data. Let's try again with 
# the nicely formatted address:
addr1 <- lapply(unlist(strsplit(res0$matchedAddress,",")),trimws)
names(addr1) <- c("street","city","state","zip")
res1 <- geocode(addr1)

# NOTE: The result is the same.
#message("Coordinates:")
#res1 %>% select(coordinates.x, coordinates.y) %>% knitr::kable()

# Compare with tidygeocoder result.
df <- data.frame(addr1=paste(addr1,collapse=" "))
res2 <- tidygeocoder::geocode(df,"addr1")
message("\nTidygeocoder coordinates:")
res2 %>% select(lat, long) %>% knitr::kable()

# What is the time to execute?
message("\nAnalyzing time to encode 100 adderesses with Censusxy...")
geocode <- function(addr) { suppressWarnings(do.call(cxy_single, addr)) } 
timing_res0 <- microbenchmark(geocode(addr0),geocode(addr1),times=100)

# As indicated by the warning, omission of zip slows things down, 
# but just a little bit.

#--------------------------------------------------------------------
## Batch Geocoding

# Subset the data--100 unique addresses.
subdt <- dt %>% filter(!duplicated(address)) %>%
	filter(address %in% sample(address, 100))

# Batch geocoding with cxy_geocode:
# NOTE: Doesn't work! 
# Failed with error:  ‘there is no package called ‘sf’’
skip = TRUE
if (!skip) {
result <- cxy_geocode(subdt, street = 'street_address', 
		      city = 'city', state = 'state')
}

#--------------------------------------------------------------------
## How long for tidygeocoder to encode these 100 addresses?

# Strip NA from addresses.
subdt$addr <- gsub(" NA","",subdt$address)

# What is the time to execute?
# Time to encode the 100 unique addresses, no zip codes:
tidygeocode <- function(addr) { subdt %>% tidygeocoder::geocode(addr) }
timing_res1 <- microbenchmark(tidygeocode(addr),times=1)

#--------------------------------------------------------------------
## Compare timing results:

# Not really a fair comparison since censusxy's comparable function
# is not working for me.

message("\nTime in seconds to encode 100 addresses with Censusxy:")
as.data.frame(timing_res0) %>% filter(expr=="geocode(addr0)") %>%
	summarize("mean"=mean(100*time)*10^-9,
		  "std" = sd(100*time)*10^-9) %>% knitr::kable()

message(paste("\nTime to encode 100 addresses with tidygeocoder:\n",
	as.numeric(as.data.frame(timing_res1)$time * 10^-9),
	"seconds.")) # Seconds.
