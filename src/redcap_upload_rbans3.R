## RBANS calculations upload
### Pre-reading
records_mod <- redcap_read_oneshot(
  redcap_uri   = uri,
  token        = token,
  events       = "3_months_arm_1",
  fields       = c("record_id","visit_data_mod") ## Only selecting relevant variables
)$data %>%
  filter(is.na(visit_data_mod)) %>% ## Only write to patients not already filled
  select(record_id) ## Keeping record_id to select for download

### Data export
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

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_rbans_lookup.R")

## Write

stts<-redcap_write(ds=df,
                   redcap_uri   = uri,
                   token        = token)

