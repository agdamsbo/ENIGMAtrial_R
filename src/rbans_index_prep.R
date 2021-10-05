# Loadning tables
source("src/rbans_tbl_read.R")

# Loading data
source("src/rbans_api_export.R")
source("src/enigma_age_calc.R")

d<-rbans_api_export(id=id,events=events,fields=c("record_id","urbans_version","rbans_a_rs","rbans_b_rs","rbans_c_rs","rbans_d_rs","rbans_e_rs"))
dts<- enigma_age_calc(id) %>% 
  filter(., redcap_event_name %in% events) %>% 
  select(.,matches(c("record_id","redcap_event_name","age"))) %>%
  mutate(age=as.integer(age))

# Conversion
source("src/index_from_raw.R")

d<-full_join(d[[1]],dts,by=c("record_id","redcap_event_name"))
d<-d[!is.na(d$urbans_version),]

df<-index_from_raw(dta = d[,1:8],version = d$urbans_version,age=d$age,raw_columns=names(d[,4:8]))

# Clean-up
source("src/remove_all_but.R")
remove_all_but(d,df)
