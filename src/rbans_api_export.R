rbans_api_export<-function(id,fields,events){
source("/Users/au301842/ENIGMA_REDCap_token.R")
library(REDCapR)
library(readr)
library(dplyr)
library(tidyr)

# fields <- c("record_id","urbans_version","rbans_a_rs","rbans_b_rs","rbans_c_rs","rbans_d_rs","rbans_e_rs")
# events<- c("3_months_arm_1","12_months_arm_1")
# id<-"1,2"

col_types <- readr::cols(
  record_id = col_double(),
  redcap_event_name = col_character(),
  redcap_repeat_instrument = col_logical(),
  redcap_repeat_instance = col_logical(),
  urbans_version = col_character(), # ARGH!!!!
  rbans_a_rs = col_character(),
  rbans_b_rs = col_character(),
  rbans_c_rs = col_character(),
  rbans_d_rs = col_character(),
  rbans_e_rs = col_character()
)

d <- redcap_read(
    redcap_uri   = uri,
    records_collapsed = id,
    token        = token,
    fields       = fields,
    col_types    = col_types
  )$data


# "%ni%" <- Negate("%in%")
# ds <- d %>% select(.,matches(c("redcap_event_name",fields))) %>% 
#   filter(., rbans_a_rs %ni% NA )

d <- d %>% select(.,matches(c("redcap_event_name",fields))) %>% 
  filter(., redcap_event_name %in% events )

d<-split(d,d$redcap_event_name)

return(d)
}
