# Basic background

inc<-c("incl_date","cpr","resist_id","nihss_baseline_sum")

field_list<-list(inc)
names(field_list)<-c("inclusion_arm_1")

source("src/redcap_api_export.R")

# RESIST participants
library(dplyr)
library(daDoctoR)
d <- redcap_api_export(fld_lst=field_list,reduced=TRUE) %>% mutate(sex=cpr_sex(cpr),age=age_calc(dob_extract_cpr(cpr),as.Date(incl_date)))%>% select(.,!cpr)

