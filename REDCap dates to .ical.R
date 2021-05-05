
source("date_file_prep.R")
source("convert_ical.R")
library(calendar)

# Formatting
df<-date_file_prep(folder="/Users/andreas/REDCap_conversion/calendar")

# Conversion
ic_write(convert_ical(start=df$value,id=df$id,event=df$name,room=df$room)[[2]], "enigma_control_all.ics")
