# Loadning tables
source("src/rbans_tbl_read.R")



# Loading data
# source("src/enigma_age_calc.R")

source("src/redcap_api_export.R")

## A problem will occur when exporting from to visits on the same subject
library(daDoctoR)

d<-full_join(redcap_api_export(id=id,fld_lst = field_list)[[-length(field_list)]],
             redcap_api_export(id=id,fld_lst = field_list)[[length(field_list)]] %>% mutate(sex=cpr_sex(cpr),age=trunc(age_calc(dob_extract_cpr(cpr),as.Date(incl_date))))%>% select(.,!cpr),
             by=c("record_id"))

# Conversion
source("src/index_from_raw.R")

df<-index_from_raw(dta = d[,c(1,3:7)],version = d$urbans_version,age=d$age,raw_columns=names(d[,3:7]))

# Clean-up
source("src/remove_all_but.R")
remove_all_but(d,df)
