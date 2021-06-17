
source("src/date_api_export.R")
source("src/date_api_export_prep.R")
source("src/convert_ical.R")
library(calendar)

# Data import from REDCap
# ds <- redcap_read(redcap_uri=uri, token=token)$data



# Formatting
df<-date_file_prep(dta=d,include_all=FALSE,cut_date=-5,num_c=2,date_col="_book",room_col = "_room",cred_path="/Users/au301842/ENIGMA_REDCap_token.R")

# Conversion
c_path<-"enigma_control.ics"
# c_path<-paste0(f_path,"enigma_control.ics")
ic_write(
  convert_ical(start=df$start,id=df$id,name=df$name,room=df$room)[[2]], file=c_path)
