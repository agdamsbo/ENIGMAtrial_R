## RBANS index upload

## Reading record_id's to mod

records_mod <- redcap_read_oneshot(
  redcap_uri   = uri,
  token        = token,
  events       = "inclusion_arm_1",
  fields       = c("record_id","incl_data_mod") ## Only selecting relevant variables
)$data %>%
  # filter(is.na(incl_data_mod)) %>% ## Only write to patients not already filled
  select(c(record_id)) ## Keeping record_id to select for download

project_start<-as.Date("2021-04-13")

source("https://raw.githubusercontent.com/agdamsbo/daDoctoR/master/R/dob_extract_cpr_function.R")

dta <- redcap_read(
  redcap_uri   = uri,
  token        = token,
  events       = c("inclusion_arm_1","3_months_arm_1","12_months_arm_1"),
  raw_or_label = "raw",
  records      = records_mod[[1]],
  fields        = c("record_id","redcap_event_name","cpr","incl_date","incl_since_start","incl_ratio","incl_data_mod","rbans_age","rbans_date") ## Only selecting relevant variables (fields)
)$data %>%
  mutate(kon=factor(ifelse(as.integer(substr(cpr, start = 10, stop = 10)) %%2 == 0, 
                           "female", "male")),
         dob=as.Date(ifelse(redcap_event_name=="inclusion_arm_1",dob_extract_cpr(cpr),NA),origin="1970-01-01"),
         age=trunc(time_length(difftime(incl_date,dob),"years")),
         incl_since_start=as.numeric(difftime(incl_date,project_start,units="weeks")),
         incl_ratio=incl_since_start/record_id,
         incl_data_mod=ifelse(redcap_event_name=="inclusion_arm_1","yes",NA)) %>% ## Calculating dob and kon
  select(-c(cpr,incl_date)) ## Dropping cpr, as to not keep in memory

for (i in unique(dta$record_id)){
  dob<-dta$dob[dta$record_id==i&dta$redcap_event_name=="inclusion_arm_1"]
  dta$rbans_age[dta$record_id==i]<-trunc(time_length(difftime(dta$rbans_date[dta$record_id==i],dob),"years"))
}


stts<-redcap_write(ds=dta,
                     redcap_uri   = uri,
                     token        = token)


