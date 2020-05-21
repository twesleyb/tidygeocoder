#!/usr/bin/env Rscript

# Load renv.
root <- dirname(dirname(getwd()))
renv::load(root)

# Other imports.
suppressPackageStartupMessages({
	library(dplyr)
	library(tidygeocoder)
	library(openRealestate)
	library(microbenchmark)
})

# Load the test data. 100 rows of Durham addresses.
datadir <- file.path(root,"data")
myfile <- file.path(datadir,"durham_test.rda")
load(myfile) # durham_test

# Create column with addresses.
df <- durham_test
df$ADDR <- paste(trimws(df$SITE_ADDR),"Durham NC")

# Encode addresses as lat/lon.
df <- df %>% geocode(ADDR) # Initial impression: geocode is slow!

# How long does it take?
message("\nEvaluating time needed to geocode 100 addresses...")
x100_rows <- df
benchmark <- microbenchmark(geocode(x100_rows,ADDR), times=3)
print(benchmark)

# How long to encode a larger dataset?
data(durham) # From openRealestate

# Calculate average time per row given the test above.
time_per_row <- mean(1/10^9 * benchmark$time/nrow(df))
time_durham <- time_per_row * nrow(durham) / (60*60) 

# Status.
message(paste("\nPredicted time to encode",formatC(nrow(durham),big.mark=","),
	      "addresses:",round(time_durham,3),"hours."))
