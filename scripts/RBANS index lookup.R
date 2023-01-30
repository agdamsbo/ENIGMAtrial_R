## =============================================================================
# RBANS Index Lookup and visualisation
## =============================================================================

## =============================================================================
## Function
## =============================================================================

library(dplyr)

## Merge with "redcap_api_export.R" function??
# source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_api_export_short.R")

## =============================================================================
## Data export
## =============================================================================

# df<-redcap_api_export_short(id= NULL,
#                             instruments= "rbans",
#                             event= c("3_months_arm_1",
#                               "12_months_arm_1")) %>%
#   select(c("record_id",
#            "redcap_event_name",
#            ends_with(c("_is","_lo","_up","_per"))))  %>%
#   na.omit()|> 
#   mutate(redcap_event_name=factor(redcap_event_name, 
#                                   levels = c("3_months_arm_1","12_months_arm_1"),
#                                   labels = c("3 months","12 months")))

library(REDCapTidieR)
read_redcap(redcap_uri = "https://redcap.au.dk/api/",
            token = keyring::key_get("enigma_api_key"),
            forms = "rbans"
            ) |> bind_tibbles()

rbans <- rbans |> 
  dplyr::select(c("record_id",
           "redcap_event",
           ends_with(c("_is","_lo","_up","_per")))) |> 
  na.omit()|> 
  dplyr::mutate(redcap_event=factor(redcap_event, 
                                  levels = c("3_months","12_months"),
                                  labels = c("3 months","12 months")))

# ins <- c("rbans")
# lis <- mget(ins)

## Next step: Plot change over time.

## =============================================================================
## Plots
## =============================================================================

source("src/plot_index.R")


# library(patchwork)
# plot_index(df)/plot_index(df,sub_plot = "_per") ## Patchwork syntax
rbans |> 
  filter(record_id %in% c(30:34),
         redcap_event == "3 months") |> 
  plot_index2()


rbans |> 
  filter(record_id %in% record_id[duplicated(record_id)]) |> # Only patients with both 3 and 12 month
  filter(record_id %in% sample(record_id,10)) |> # 5 random patients
  # filter(record_id %in% 28:32) |> # Only specified number
  plot_index(id="redcap_event",facet.by = "record_id")



sub.fil <- c(28:32)
sub.fil <- sample(df$record_id,5)

# Time plot compared with own
rbans |> 
  # filter(record_id %in% record_id[duplicated(record_id)]) |> # Only patients with both 3 and 12 month
  # filter(record_id %in% sample(record_id,5)) |> # 5 random patients
  filter(record_id %in% 30:34) |> # Only specified number
  plot_index(id="redcap_event",facet.by = "record_id")

# ggsave("example.png")

# Time plot compared during follow-up
rbans |> 
  # filter(record_id %in% sub.fil) |>
  plot_index(id="record_id",facet.by = "redcap_event")

