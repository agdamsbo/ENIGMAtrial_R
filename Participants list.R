# Inclusion status

inc<-c("incl_date","first_name","resist_id")

field_list<-list(inc)
names(field_list)<-c("inclusion_arm_1")

source("src/redcap_api_export.R")

# RESIST participants
d <- redcap_api_export(fld_lst=field_list,reduced=TRUE) %>% filter(.,!is.na(resist_id))

write.csv(d,paste0("/Users/au301842/ENIGMA_exports/enigma_resist_list_",lubridate::today(),".csv"))
