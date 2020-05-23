#!/usr/bin/env Rscript

# Load renv.
root <- dirname(dirname(getwd()))
if (file.exists(file.path(root,"renv"))) { renv::load(root) }

# Other imports.
suppressPackageStartupMessages({
	library(dplyr)
	library(tidygeocoder)
	library(openRealestate)
})

# How long to encode a larger dataset?
data(durham) # From openRealestate

# Create column with addresses.
durham$ADDR <- paste(trimws(durham$SITE_ADDR),"Durham NC")

# Encode addresses as lat/lon.
message(paste("Starting geocoding at:",Sys.time()))
durham <- durham %>% geocode(ADDR)

# Save to file.
message(paste("Completed geocoding at:",Sys.time()))
fwrite(durham,"durham.csv")
