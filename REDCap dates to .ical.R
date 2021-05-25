
source("src/date_file_prep.R")
source("src/convert_ical.R")
library(calendar)

# Formatting
f_path<-"/Users/andreas/REDCap_conversion/calendar"
df<-date_file_prep(folder=f_path,include_all=FALSE,cut_date=-5,num_c=2,date_col="_book",room_col = "_room")

# Conversion
c_path<-paste0(f_path,"/enigma_control.ics")
ic_write(
  convert_ical(start=df$start,id=df$id,name=df$name,room=df$room)[[2]], file=c_path)
