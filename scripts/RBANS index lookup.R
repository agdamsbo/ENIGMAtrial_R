## =============================================================================
# RBANS Index Lookup and visualisation
## =============================================================================

## =============================================================================
# RBANS data modification
## =============================================================================

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/scripts/Modification.R")

## =============================================================================
## Function
## =============================================================================

library(dplyr)

## Merge with "redcap_api_export.R" function??
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_api_export_short.R")

## =============================================================================
## Data export
## =============================================================================

df<-redcap_api_export_short(id= c(40:60),
                            instruments= "rbans",
                            event= "3_months_arm_1") %>%
  select(c("record_id",ends_with(c("_is","_lo","_up","_per")))) %>%
  na.omit()

## Next step: Plot change over time.

## =============================================================================
## Plots
## =============================================================================

source("src/plot_index.R")
source("src/plot_percentile.R")

plot_index(df)/plot_percentile(df) ## Patchwork syntax


