# Test index, percentile and ci calculations from raw scores exported from REDCap server

## RBANS index conversion
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/index_from_raw.R")

## TABLE LOOKUPS
### Requires data to be in dta
df<-cbind(index_from_raw(dta = select(dta,c("record_id",ends_with("_rs"))),
                         table=read.csv("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/data/index.csv"),
                         version = dta$urbans_version,
                         age=dta$rbans_age,
                         raw_columns=names(select(dta,ends_with("_rs")))),redcap_event_name=dta$redcap_event_name)

colnames(df)<-c("record_id",colnames(cbind(select(dta,ends_with("_is")),select(dta,ends_with("_ci")),select(dta,ends_with("_per")))),"redcap_event_name")
