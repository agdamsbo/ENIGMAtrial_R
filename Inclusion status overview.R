# Inclusion status

inc<-c("incl_date")
eos<-c("eos1","eos2","eos3")

field_list<-list(inc,eos)
names(field_list)<-c("inclusion_arm_1","end_of_study_arm_1")

source("src/redcap_api_export.R")
d<-redcap_api_export(fld_lst=field_list,reduced=TRUE)

# Visuals
source("src/status_plot.R")
gridExtra::grid.arrange(p1, p2, nrow=1, ncol=2)
# p1
# p2
