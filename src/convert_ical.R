convert_ical<-function(start,id,time=7200,name,room){
  library(calendar)
  # Package from here: https://github.com/ATFutures/calendar/
  library(lubridate)
  library(dplyr)
  # Standard event duration is 7200s=2h
  # Converts list of single event times to calendar entries for each ID with duration of standard length
  # Based on example from https://github.com/ATFutures/calendar/issues/36
  fix <-  data.frame(SUMMARY = paste0("ID", id, " ",name),
                     DTSTART = ymd_hm(start,tz="CET"),
                     DTEND = ymd_hm(start,tz="CET")+time,
                     LOCATION = room,
                     stringsAsFactors = FALSE)
  fix<-fix %>% mutate(UID = replicate(nrow(fix), ic_guid()))
  ic <- ical(fix[!is.na(fix$DTSTART),])
  return(list(fix,ic))
}
