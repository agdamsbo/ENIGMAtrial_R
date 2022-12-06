source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_api_export_short.R")

## =============================================================================
## Data export
## =============================================================================

score<-redcap_api_export_short(id= c(1:35),
                            instruments= "rbans",
                            event= c("3_months_arm_1",
                                     "12_months_arm_1")) %>%
  select(c("record_id",
           "redcap_event_name",
           ends_with(c("_is","_lo","_up","_per"))))  %>%
  na.omit() |> 
  mutate(redcap_event_name=factor(redcap_event_name, 
                                  levels = c("3_months_arm_1","12_months_arm_1"),
                                  labels = c("A","B"))) |> 
  filter(record_id %in% record_id[duplicated(record_id)]) |> # Only patients with both 3 and 12 month
  filter(record_id %in% sample(record_id,10)) |>
  mutate(record_id = rep(seq_along(unique(record_id)), each=2))

names(score) <- unlist(lapply(strsplit(colnames(score),"_"),function(x){
  paste0(x[-1],collapse="_")
}))

names(score)[2]<-"event"

attr(score,which = "na.action") <- NULL

save(score,file = "score.rda")
