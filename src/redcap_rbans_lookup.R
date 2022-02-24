# Test index, percentile and ci calculations from raw scores exported from REDCap server

## RBANS index conversion
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/index_from_raw.R")
index<-read.csv("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/data/index.csv")

## TABLE LOOKUPS
### Requires data to be in dta
df<-cbind(index_from_raw(dta = select(dta,c("record_id",ends_with("_rs"))),
                         indx=index,
                         version = dta$urbans_version,
                         age=dta$rbans_age,
                         raw_columns=names(select(dta,ends_with("_rs")))),redcap_event_name=dta$redcap_event_name)

colnames(df)<-c("record_id",colnames(cbind(select(dta,ends_with("_is")),select(dta,ends_with("_ci")),select(dta,ends_with("_per")))),"redcap_event_name")

sel1<-colnames(select(df,ends_with("_per")))
for (i in sel1){
  df[,i]<-if_else(df[,i]=="> 99.9","99.95",
                 if_else(df[,i] =="< 0.1", "0.05",
                                  df[,i]))
  ## Using the dplyr::if_else for a more stringent vectorisation
}

ds<-replace(df, TRUE, lapply(df, type.convert)) ## Converting types
