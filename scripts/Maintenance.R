# maintenance

source("scripts/Modification.R")

## =============================================================================
## Update calendar
## =============================================================================


source(here::here("scripts/REDCap dates to .ical with API.R"))
enigma_calendar_update(allow.stops = FALSE)
