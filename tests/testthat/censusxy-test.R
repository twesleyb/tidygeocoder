#!/usr/bin/env Rscript

# The censusxy package provides easy access to the U.S. Census Bureau's
# Geocoding Tools: https://geocoding.geo.census.gov/geocoder/ in R.
# These tools allow for unlimited, free geocoding.

# Installation
# install.packages("censusxy")
# devtools::install_github("slu-openGIS/censusxy")

# NOTE: Installation failed because of units dependency.
# The 'sf' option in the central cxy_geocode function utilzes the
# 'sf' package, which in turn relies upon the units library.
# I've forked the repo and just removed any calls to 'sf'.

# Try using my fork:
#devtools::install_github("twesleyb/census_xy")

# Load renv.
renv::load(getrd())

# Load twesleyb/censusxy and additional libs:
suppressPackageStartupMessages({
	library(censusxy)
	library(microbenchmark)
	library(tidygeocoder)
	library(dplyr)
})

# Load the test data.
data(stl_homicides)

# NOTE: On parsing addresses with censusxy:
# Dataframe or alike object should contain seperate columns for:
# * street address - required; the rest are optional.
# * city
# * state 
# * zipcode

#--------------------------------------------------------------------
# Try batch Geocoding

run_chunk <- FALSE
if (run_chunk) { 
# Time to geocode the homicide_sf dataset:
n_addrs <- nrow(stl_homicides)
message(paste("\nAnalyzing time to encode", formatC(n_addrs,big.mark=","),
	      "addresses with censusxy::cxy_geocode..."))
start <- Sys.time()
homicide_sf <- cxy_geocode(stl_homicides, street = 'street_address', 
			   city = 'city', state = 'state')
end <- Sys.time()

# Results:
delta_t <- difftime(end,start,units="secs")
message(paste("Time to geocode", formatC(n_addrs,big.mark=","), 
	      "addresses:", round(delta_t/60,3),"minutes"))
message(paste("Average time per row:",round(as.numeric(delta_t/n_addrs),3),
	"seconds."))

# Print the result:
#knitr::kable(head(homicide_sf))

}

# NOTE: Worked BUT, very slow.
# NOTE: Not working on my pc, fails with curl error:
# Empty reply from server.

#---------------------------------------------------------------------
# Compare time taken to encode a single address with tidygeocoder.

# Add column with complete addresses for tidygeocoder.
df <- stl_homicides
df$address <- paste(df$street_address,df$city,
		    df$state,sep=" ")

# Get a random address.
set.seed(as.numeric(Sys.time()))
df <- df %>% filter(!duplicated(address))
address <- df %>% filter(address == sample(address,1)) %>% 
	select(street_address,city,state) %>% as.list()
names(address)[1] <- "street"
message(paste("\nGeocoding a single address:", 
	      paste(unlist(address), collapse=" ")))

# A function to perform geocoding with cxy_single:
geocode <- function(addr) { suppressWarnings(do.call(cxy_single, addr)) } 
# geocode(address)

# A function to do an equivalent operation with tidygeocoder:
# NOTE: tidygeocoder takes a df as input, so for a fair comparison
# let's do this little bit of work before hand.
df <- data.frame("address"=paste(address,collapse=" "))
geocode_tidy <- function(df) { tidygeocoder::geocode(df,"address") }

# Run experiment:
message("\nAnalyzing time to encode 100 adderesses...")
result <- microbenchmark(geocode(address), geocode_tidy(df), times=100)

# Check mean time for each:
result_df <- as.data.frame(result) %>% 
	group_by(expr) 
result_df %>% summarize(Mean=mean(time*10^-6)) %>% knitr::kable()

# The result is clear, tidygeocoder is much faster.
