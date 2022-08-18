## RBANS calculations upload
### Pre-reading
records_mod <- redcap_read_oneshot(
  redcap_uri   = uri,
  token        = token,
  events       = "3_months_arm_1",
  fields       = c("record_id","visit_data_mod","rbans_perf") ## Only selecting relevant variables
)$data

if (all_ids_3==FALSE){
  # IDs with performed RBANS, and not yet modified
  ids<-setdiff(records_mod$record_id[!is.na(records_mod$rbans_perf==1)], #IDs with 12 months RBANS performed
               na.omit(records_mod$record_id[records_mod$visit_data_mod=="yes"]) #IDs with data modified already
  ) 
}

if (all_ids_3==TRUE){
  ## Set all IDs for reupload
  ids<-records_mod$record_id[!is.na(records_mod$rbans_perf==1)]
}


if (length(ids)>0){
### Data export
dta <- redcap_read(
  redcap_uri   = uri,
  token        = token,
  events       = "3_months_arm_1",
  raw_or_label = "raw",
  records      = ids,
  forms        = "rbans",
  fields       = "record_id"
)$data
  

## Handling only 3 months data

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_rbans_lookup.R")

## Write

stts<-redcap_write(ds=df%>%mutate(visit_data_mod="yes"), ## Last minute flag to indicate modification performed
                   redcap_uri   = uri,
                   token        = token)
}
