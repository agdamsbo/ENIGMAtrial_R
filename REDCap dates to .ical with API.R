
# REDCap data export/import script
source("src/date_api_export.R")

# Formatting
source("src/date_api_export_prep.R")
df<-date_api_export_prep(dta=d,include_all=FALSE,cut_date=-5,num_c=2,date_col="_book",room_col = "_room")
## Includes only one appointment for each ID. Problem?

## Excluding patients with booking, but with EOS filled due to early end of study (ie date of EOS not blank)
df<-df[df$id!=d$record_id[!is.na(d$eos1)],]

# Conversion
library(calendar)
source("src/convert_ical.R")
ic_write(convert_ical(start=df$start,id=df$id,name=df$name,room=df$room)[[2]], file="enigma_control.ics")

# Commit and push GIT
source("src/enigma_git_push.R")
enigma_git_push("calendar update")
