# RBANS Index Lookup and visualisation

events = "3_months_arm_1"
id   = "17,18"

suppressWarnings(source("src/rbans_index_prep.R"))

# - NAs are just thrown out.

## Now includes all relevant data. Maybe include event in df?

source("src/rbans_plot.R")

grid.arrange(index_plot, percentile_plot, nrow=2, ncol=1)
