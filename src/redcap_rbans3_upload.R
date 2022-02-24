## RBANS calculations upload

# Index loading
index<-read.csv("/Users/au301842/ENIGMAtrial_R/index/index.csv")

# RBANS index conversion
source("src/index_from_raw.R")

records_mod <- redcap_read_oneshot(
  redcap_uri   = uri,
  token        = token,
  events       = "3_months_arm_1",
  fields       = c("record_id","visit_data_mod") ## Only selecting relevant variables
)$data %>%
  filter(is.na(visit_data_mod)) %>% ## Only write to patients not already filled
  select(c(record_id)) ## Keeping record_id to select for download


d <- redcap_read(
  redcap_uri   = uri,
  token        = token,
  events       = "3_months_arm_1",
  raw_or_label = "raw",
  records      = records_mod[[1]],
  forms        = "rbans"
)$data 

# %>% select(c(contains("rbans"),record_id,redcap_event_name,age)) %>% 
#   filter((!is.na(rbans_perf)|!is.na(age))&is.na(rbans_e_ci)) %>% ## Logikken her halter lige lidt
#   split(.$redcap_event_name) 

## Herunder skal der laves en bedre håndtering af både 3 og 12 mdr.

df<-cbind(index_from_raw(dta = select(d$`3_months_arm_1`,c("record_id",ends_with("_rs"))),
                   table=index,
                   version = d$`3_months_arm_1`$urbans_version,
                   age=d$inclusion_arm_1$age,
                   raw_columns=names(select(d$`3_months_arm_1`,ends_with("_rs")))),
          redcap_event_name="3_months_arm_1") ## include event_name

colnames(df)<-c("record_id",colnames(cbind(select(d[[1]],ends_with("_is")),select(d[[1]],ends_with("_ci")),select(d[[1]],ends_with("_per")))),"redcap_event_name")

## Write

# stts<-redcap_write(ds=df,
#                    redcap_uri   = "https://redcap.au.dk/api/",
#                    token        = names(suppressWarnings(read.csv("/Users/au301842/enigma_redcap_token.csv"))))

## Missing now:
## - set correct variable names for upload
## - include event_name
