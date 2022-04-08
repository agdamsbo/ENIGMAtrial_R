## =============================================================================
# RBANS Index Lookup and visualisation
## =============================================================================

## =============================================================================
# RBANS data modification
## =============================================================================

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/auto/data_modification.R")

## =============================================================================
## Function
## =============================================================================

library(dplyr)

## Merge with "redcap_api_export.R" function??
source("src/redcap_api_export_short.R")

## =============================================================================
## Data export
## =============================================================================

df<-redcap_api_export_short(id= 40,
                            instruments= "rbans",
                            event= "3_months_arm_1") %>%
  select(c("record_id",ends_with(c("_is","_lo","_up","_per")))) %>%
  na.omit()

## Next step: Plot change over time.

## =============================================================================
## Plots
## =============================================================================

source("src/rbans_plot.R")

index_plot/percentile_plot ## Patchwork syntax


