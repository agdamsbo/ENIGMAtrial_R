# Specific functions used

watch_folder_csv <- function (folder) {
  f <- folder
  pt <- ".csv"
  p <- list.files(f, pattern = pt, full.names = TRUE)
  d <- read.csv(p, header = TRUE, sep = ";")
  return(list(d,p))
}



unlist(strsplit(watch_folder_csv("/Users/andreas/REDCap_conversion/calendar")[[2]], "[_]"))


convert_ical<-function(start,id,time=7200,event="3 mdr",room="J109"){
  library(calendar)
  # Package from here: https://github.com/ATFutures/calendar/
  library(lubridate)
  library(dplyr)
  # Standard event duration is 7200s=2h
  # Converts list of single event time to calendar entries for each ID with duration of standard length
  # Based on example from https://github.com/ATFutures/calendar/issues/36
  fix <-  data.frame(SUMMARY = paste0("ID", id, " ",event),
                     DTSTART = ymd_hm(start,tz="CET"),
                     DTEND = ymd_hm(start,tz="CET")+time,
                     LOCATION = room,
                     stringsAsFactors = FALSE)
  fix<-fix %>% mutate(UID = replicate(nrow(fix), ic_guid()))
  ic <- ical(fix[!is.na(fix$DTSTART),])
  return(list(fix,ic))
}


# Conversion

d<-watch_folder_csv("/Users/andreas/REDCap_conversion/calendar")[[1]]

p<-convert_ical(start=d$incl_book3,id=d$record_id)

ic_write(convert_ical(start=d$incl_book3,id=d$record_id)[[2]], "fixtures.ics")
