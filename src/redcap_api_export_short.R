## Merge with "redcap_api_export.R" function??

items      = "record_id"
instruments= "rbans"

df <- redcap_read_oneshot(
  redcap_uri   = "https://redcap.au.dk/api/",
  token        = names(suppressWarnings(read.csv("/Users/au301842/enigma_redcap_token.csv",colClasses = "character"))),
  events       = event,
  records      = id,
  forms        = instruments,
  fields       = items
)$data 
