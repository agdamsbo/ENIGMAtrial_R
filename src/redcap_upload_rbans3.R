## RBANS calculations upload

# Index loading
index<-read.csv("/Users/au301842/ENIGMAtrial_R/data/index.csv")

# RBANS index conversion
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/index_from_raw.R")

records_mod <- redcap_read_oneshot(
  redcap_uri   = uri,
  token        = token,
  events       = "3_months_arm_1",
  fields       = c("record_id","visit_data_mod") ## Only selecting relevant variables
)$data %>%
  filter(is.na(visit_data_mod)) %>% ## Only write to patients not already filled
  select(record_id) ## Keeping record_id to select for download


dta <- redcap_read(
  redcap_uri   = uri,
  token        = token,
  events       = "3_months_arm_1",
  raw_or_label = "raw",
  records      = records_mod[[1]],
  forms        = "rbans",
  fields       = "record_id"
)$data  %>% 
  filter(rbans_perf==1)

## Handling only 3 months by script also for 12 months handling

df<-cbind(index_from_raw(dta = select(dta,c("record_id",ends_with("_rs"))),
                   table=index,
                   version = dta$urbans_version,
                   age=dta$rbans_age,
                   raw_columns=names(select(dta,ends_with("_rs")))),redcap_event_name=dta$redcap_event_name)

colnames(df)<-c("record_id",colnames(cbind(select(dta,ends_with("_is")),select(dta,ends_with("_ci")),select(dta,ends_with("_per")))),"redcap_event_name")

## Write

# stts<-redcap_write(ds=df,
#                    redcap_uri   = uri,
#                    token        = token)

