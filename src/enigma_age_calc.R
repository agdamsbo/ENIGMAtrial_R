# No use anymore!!

enigma_age_calc<-function(id){
  ## id is ID-numbers seperated by ","
  
source("/Users/au301842/ENIGMA_REDCap_token.R")
library(REDCapR)
library(readr)
library(dplyr)
library(tidyr)
library(daDoctoR)

# id <- "1,2"

col_types <- readr::cols(
  record_id = col_double(),
  redcap_event_name = col_character(),
  redcap_repeat_instrument = col_logical(),
  redcap_repeat_instance = col_logical(),
  rbans_date = col_character(),
  cpr = col_character(),
  incl_date = col_character()
)

d <- redcap_read(
  redcap_uri   = uri,
  records_collapsed = id,
  token        = token,
  fields       = c("record_id","cpr","incl_date","rbans_date"),
  col_types    = col_types
)$data %>% 
  mutate(.,cpr=dob_extract_cpr(cpr))

dc <- d  %>% select(.,matches(c("record_id","incl_date","rbans_date","redcap_event_name","cpr"))) %>% 
  filter(., redcap_event_name %in% c("inclusion_arm_1","3_months_arm_1","12_months_arm_1")) %>% 
  unite(.,col = dates,matches(c("incl_date","rbans_date")),na.rm=T)

dc$dates<-parse_date(
  dc$dates,
  format = "%Y-%m-%d",
  na = c(""),
  locale = default_locale(),
  trim_ws = TRUE
)

for (i in 1:nrow(dc)){
  if (is.na(dc$dates[i])|is.na(dc$cpr[i])){
    dc$age[i]<-NA
  }
  else{dc$age[i]<-age_calc(dc$cpr[i],dc$dates[i])
}}

# dc<-dc %>% pivot_wider(id_cols=c("record_id"), names_from = "redcap_event_name", values_from = c("dates","age"))

return(dc)
}

