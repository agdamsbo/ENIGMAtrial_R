library(REDCapR)
library(readr)

fields <- c("record_id", "incl_book3", "incl_room3", "incl_other3", "visit_book12", "visit_room12", "visit_other12","eos1")
col_types <- readr::cols(
  record_id = col_double(),
  redcap_repeat_instance = col_logical(),
  incl_book3 = col_character(),
  incl_room3 = col_character(),
  incl_other3 = col_character(),
  visit_book12 = col_character(),
  visit_room12 = col_character(),
  visit_other12 = col_character(),
  eos1 = col_character()
)

d <- redcap_read(
    redcap_uri   = "https://redcap.au.dk/api/",
    token        = token,
    fields       = fields,
    col_types    = col_types
  )$data
  

# Clean-up
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/remove_all_but.R")
remove_all_but(d)
