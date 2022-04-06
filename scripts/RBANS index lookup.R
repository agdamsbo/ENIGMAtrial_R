## =============================================================================
# RBANS Index Lookup and visualisation
## =============================================================================


## =============================================================================
## Settings
## =============================================================================

id         = 40

event      = "3_months_arm_1"

## =============================================================================
## Data export
## =============================================================================

## Use "redcap_api_export.R" function instead??

source("src/redcap_api_export_short.R")

df <- df %>%
  select(c("record_id",ends_with(c("_is","_lo","_up","_per")))) %>%
  na.omit()

## Now includes all relevant data. Maybe include event in df? This would enable the analysis of change in score. Requires different plotting

## =============================================================================
## Plots
## =============================================================================

source("src/rbans_plot.R")

index_plot/percentile_plot ## Patchwork syntax


