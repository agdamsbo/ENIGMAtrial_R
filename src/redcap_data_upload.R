## RBANS index upload

library(REDCapR)
library(dplyr)
library(daDoctoR)

## Just perform simple dob-calculation and sex

dta <- redcap_read_oneshot(
  redcap_uri   = "https://redcap.au.dk/api/",
  token        = names(suppressWarnings(read.csv("/Users/au301842/enigma_redcap_token.csv",colClasses = "character"))),
  events       = "inclusion_arm_1", ## Selecting relevant events
  raw_or_label = "raw"
)$data %>% 
  select(c("record_id","redcap_event_name","cpr","incl_date")) %>%  ## Only selecting relevant variables
  # filter(is.na(age)) %>% ## Only write to fields not already filled
  mutate(kon=cpr_sex(cpr),dob=dob_extract_cpr(cpr),age=trunc(age_calc(dob,incl_date))) %>% ## Calculating dob and kon
  select(-c(cpr,incl_date)) ## Dropping cpr, as to not keep in memory


# stts<-redcap_write(ds=dta,
#                      redcap_uri   = "https://redcap.au.dk/api/",
#                      token        = names(suppressWarnings(read.csv("/Users/au301842/enigma_redcap_token.csv"))))


