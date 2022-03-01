## RBANS calculations upload
### Pre-reading
records_mod <- redcap_read_oneshot(
  redcap_uri   = uri,
  token        = token,
  events       = "12_months_arm_1",
  fields       = c("record_id","eos_data_mod","rbans_perf") ## Only selecting relevant variables
)$data %>%
  filter(is.na(eos_data_mod)) %>% ## Only write to patients not already filled
  filter(rbans_perf==1) %>% ## The two filters are kept seperated for troubleshooting
  select(record_id) ## Keeping record_id to select for download

if (length(records_mod[[1]])>0){
### Data export
dta <- redcap_read(
  redcap_uri   = uri,
  token        = token,
  events       = "12_months_arm_1",
  raw_or_label = "raw",
  records      = records_mod[[1]],
  forms        = "rbans",
  fields       = "record_id"
)$data
  

## Handling 12 months

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_rbans_lookup.R")

## Composing standard conclusion text



## Write
stts<-redcap_write(ds=df%>%mutate(eos_data_mod="yes"), ## Last minute flag to indicate modification performed
                   redcap_uri   = uri,
                   token        = token)
}
