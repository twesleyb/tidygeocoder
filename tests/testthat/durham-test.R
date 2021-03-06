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

#--------------------------------------------------------------------
## How long to encode a larger dataset?
data(durham) # From openRealestate

# Create column with addresses.
durham$ADDR <- paste(trimws(durham$SITE_ADDR),"Durham NC")

# Encode addresses as lat/lon.
start <- Sys.time()
message(paste("\nStarting geocoding at:",start))
durham <- durham %>% geocode(ADDR)

# Status.
now <- Sys.time()
dt <- difftime(now,start)
message(paste0("\nCompleted geocoding at: ", now))
message(paste0("\nTime to encode ", 
	       formatC(nrow(durham), big.mark=","), " rows: ",
	       round(dt,3), " ", attr(dt,"units"),"."))

# Save to file.
data.table::fwrite(durham,"durham.csv")

#--------------------------------------------------------------------
## How many missing values?

durham <- data.table::fread("durham.csv")

is_missing <- is.na(durham$lat) & is.na(durham$long)
percent_missing <- 100*sum(is_missing)/length(is_missing)
message(paste("Percent addresses with missing lat/long:",
	      round(percent_missing,2),"(%)."))

