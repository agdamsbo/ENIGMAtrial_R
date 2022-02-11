# RBANS Index Lookup and visualisation

## This forces wide data, but should be kept as long and indexed by event name

inc<-c("record_id","age")
mn3<-c("record_id","urbans_version","rbans_a_rs","rbans_b_rs","rbans_c_rs","rbans_d_rs","rbans_e_rs")

field_list<-list(inc,
                 mn3)


names(field_list)<-c("inclusion_arm_1",
                     "3_months_arm_1")

id   = "1"

suppressWarnings(source("src/rbans_index_prep.R"))

# - NAs are just thrown out.

## Now includes all relevant data. Maybe include event in df? This would enable the analysis of change in score. Requires different plotting.

source("src/rbans_plot.R")

grid.arrange(index_plot, percentile_plot, nrow=2, ncol=1)

## Use kable package for beautiful table
