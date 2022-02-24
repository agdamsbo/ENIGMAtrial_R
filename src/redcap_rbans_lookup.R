# Test index, percentile and ci calculations from raw scores exported from REDCap server

## RBANS index conversion
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/index_from_raw.R")
# source("src/index_from_raw.R")

## TABLE LOOKUPS
### Requires data to be in dta
df<-cbind(index_from_raw(ds = select(dta,c("record_id",ends_with("_rs"))),
                         indx=read.csv("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/data/index.csv"),
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

## Spliting CIs in lower and upper
loups<-c()
for (i in 1:nrow(df)){
  # i=34
  cis<-c()
  for (j in colnames(select(df,ends_with("_ci")))){
    # j="rbans_a_ci"
    cis<-c(cis,unlist(strsplit(df[i,j],split="[-]")))
  }
  loups<-c(loups,c(df$record_id[i],cis))
}
loups<-data.frame(matrix(loups,ncol = 13,byrow = TRUE))

### Naming and merging
cnms<-c()
for (k in colnames(select(df,ends_with("_ci")))){
  # j="rbans_a_ci"
  stp<-unlist(strsplit(k,split="[_]"))[-3]
  cnms<-c(cnms,paste0(paste(stp,collapse = "_"),"_",c("lo","up")))
}

colnames(loups)<-c("record_id",cnms)

loups$record_id<-as.numeric(loups$record_id)

df<-merge(df,loups)

## Type conversion
csel<-colnames(select(df,!ends_with("_ci"))) ## Not including "_ci" as these should stay as character
df[,csel]<-replace(df[,csel], TRUE, lapply(df[,csel], type.convert)) ## Converting types
