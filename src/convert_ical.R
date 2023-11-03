convert_ical<-function(df,start,id,hours=2,name,room){
  library(calendar)
  # Package from here: https://github.com/ATFutures/calendar/
  library(lubridate)
  library(dplyr)
  # Standard event duration is 7200s=2h
  # Converts list of single event times to calendar entries for each ID with duration of standard length
  # Based on example from https://github.com/ATFutures/calendar/issues/36
  fix <-  tibble(SUMMARY = paste0("ID", df[[id]], " ",df[[name]]),
                     DTSTART = ymd_hms(df[[start]],tz="CET"),
                     DTEND = DTSTART+time_length(hours*3600*60*60,unit = "hours"),
                     LOCATION = df[,room],
                     stringsAsFactors = FALSE)
  fix<-fix %>% mutate(UID = replicate(nrow(fix), ic_guid()))
  ic <- ical(fix[!is.na(fix$DTSTART),])
  
  list(fix,ic)
}
