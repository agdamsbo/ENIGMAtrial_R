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

df<-redcap_api_export_short(id= NULL,
                            instruments= "rbans",
                            event= c("3_months_arm_1",
                              "12_months_arm_1")) %>%
  select(c("record_id",
           "redcap_event_name",
           ends_with(c("_is","_lo","_up","_per"))))  %>%
  na.omit()|> 
  mutate(redcap_event_name=factor(redcap_event_name, 
                                  levels = c("3_months_arm_1","12_months_arm_1"),
                                  labels = c("3 months","12 months")))

## Next step: Plot change over time.

## =============================================================================
## Plots
## =============================================================================

source("src/plot_index.R")


# library(patchwork)
# plot_index(df)/plot_index(df,sub_plot = "_per") ## Patchwork syntax
df |> 
  filter(record_id %in% c(34),
         redcap_event_name == "3 months") |> 
  plot_index2()



df |> 
  filter(record_id %in% record_id[duplicated(record_id)]) |> # Only patients with both 3 and 12 month
  filter(record_id %in% sample(record_id,10)) |> # 5 random patients
  # filter(record_id %in% 28:32) |> # Only specified number
  plot_index(id="redcap_event_name",facet.by = "record_id")



sub.fil <- c(28:32)
sub.fil <- sample(df$record_id,5)

# Time plot compared with own
df |> 
  # filter(record_id %in% record_id[duplicated(record_id)]) |> # Only patients with both 3 and 12 month
  # filter(record_id %in% sample(record_id,5)) |> # 5 random patients
  filter(record_id %in% 30:34) |> # Only specified number
  plot_index(id="redcap_event_name",facet.by = "record_id")

# ggsave("example.png")

# Time plot compared during follow-up
df |> 
  # filter(record_id %in% sub.fil) |>
  plot_index(id="record_id",facet.by = "redcap_event_name")

