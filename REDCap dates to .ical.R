
source("date_file_prep.R")
source("convert_ical.R")
library(calendar)

# Formatting
f_path<-"/Users/andreas/REDCap_conversion/calendar"
df<-date_file_prep(folder=f_path,include_all=FALSE,cut_date=-5,num_c=1,ev_names=c("3mdr"),col_spec="_book3")

## Room variable is set as fixed value, change when REDCap is updated.

# Conversion
ic_write(convert_ical(start=df$value,id=df$id,event=df$name,room=df$room)[[2]], "enigma_control_all.ics")
