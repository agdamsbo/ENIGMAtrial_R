# NOTER
# 
# Kun upload i Google Chrome (!)
# 
# Brug "Bulk Edit Calendar Events" program til at fjerne, 
# forud for upload i samme tidsrum.
# 

df <-
  readODS::read_ods("/Users/au301842/Desktop/jc2023.ods")

output <- paste0(
  "/Users/au301842/Desktop/jc2023",Sys.Date(),".ics")

df$Dato <-
  lubridate::dmy(paste0(df$Dato, "/", format(Sys.Date(), format = "%Y")))

fdf_ical <-
  function(df,
           date,
           title,
           time.start,
           time.end,
           place,
           time.def = "18:00:00",
           time.dur = 5400) {
    library(calendar)
    # Package from here: https://github.com/ATFutures/calendar/
    library(lubridate)
    library(dplyr)
    # Standard event duration is 5400s=1.5h
    # Converts list of single event times to calendar entries for each ID with duration of standard length
    # Based on example from https://github.com/ATFutures/calendar/issues/36
    
    place_meet <- if_else(is.na(df[, place]),
                          "J119",
                          df[, place])
    
    start_time <- if_else(is.na(df[, time.start]),
                          ymd_hms(paste(df[, date], time.def), tz = "CET"),
                          ymd_hms(paste(df[, date], df[, time.start]), tz = "CET"))
    
    end_time <- if_else(is.na(df[, time.end]),
                        start_time + time.dur,
                        ymd_hms(paste(df[, date], df[, time.end]), tz =
                                  "CET"))
    
    fix <-  data.frame(
      SUMMARY = df[, title],
      DTSTART = start_time,
      DTEND = end_time,
      LOCATION = place_meet,
      stringsAsFactors = FALSE
    )
    
    fix %>% mutate(UID = replicate(nrow(fix), ic_guid())) |> 
      ical()
  }

df |> mutate(Program=paste0(`Ansvarlig `," [",`Vejleder `,"]"),
             Start="09:00:00",
             Slut="10:00:00") |> 
  fdf_ical(
    date = "Dato",
    title = "Program",
    time.start = "Start",
    time.end = "Slut"
  ) |>  calendar::ic_write(file = output)

