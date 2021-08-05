
# REDCap data export/import script
source("src/date_api_export.R")

# Formatting
source("src/date_api_export_prep.R")
## Excluding patients with booking, but with EOS filled due to early end of study (ie date of EOS not blank)
dt<-d[is.na(d$eos1),]

df<-date_api_export_prep(dta=dt,include_all=FALSE,cut_date=-5,num_c=2,date_col="_book",room_col = "_room")

# Conversion
library(calendar)
source("src/convert_ical.R")
ic_write(convert_ical(start=df$start,id=df$id,name=df$name,room=df$room)[[2]], file="enigma_control.ics")

# Commit and push GIT
# library(git2r)
git2r::commit(all=TRUE, message=paste("calendar update",now()))

system("/usr/bin/git push origin HEAD:refs/heads/main")
