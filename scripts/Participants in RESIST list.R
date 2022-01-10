# Inclusion status

inc<-c("incl_date","first_name","resist_id")
field_list<-list(inc)
names(field_list)<-c("inclusion_arm_1")

source("src/redcap_api_export.R")

# RESIST participants
library(tidyverse)

after_id<-10940 # Oldest RESIST ID to include in export

d <- redcap_api_export(fld_lst=field_list,reduced=TRUE) %>% 
  filter(.,!is.na(resist_id) &     # Only include patients with recorded RESIST ID
           resist_id>=after_id)    # Only IDs above or equal to set ID

## Dated export list
write.csv(d,paste0("/Users/au301842/ENIGMA_exports/enigma_resist_list_",lubridate::today(),".csv"))
