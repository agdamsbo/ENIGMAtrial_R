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

df<-redcap_api_export_short(id= c(35),
                            instruments= "rbans",
                            event= c("3_months_arm_1","12_months_arm_1")) %>%
  select(c("record_id",
           "redcap_event_name",
           ends_with(c("_is","_lo","_up","_per")))) %>%
  na.omit()
    

## Next step: Plot change over time.

## =============================================================================
## Plots
## =============================================================================

# Facet by
# - instance/event? > done
# - id > done
# - no facet > done

source("src/plot_index.R")


library(patchwork)
plot_index(df)/plot_index(df,sub_plot = "_per") ## Patchwork syntax

# Time plot compared with own
plot_index(df,id="redcap_event_name",facet.by = "record_id")

