## Merge with "redcap_api_export.R" function??

redcap_api_export_short<-function(event,id,instruments,items = "record_id"){
  require(REDCapR)
  # event = specific event desired
  # id    = patient IDs to export
  # instruments = instruments
  # items = extra items in addition to instruments
  
redcap_read_oneshot(
  redcap_uri   = "https://redcap.au.dk/api/",
  token        = names(suppressWarnings(read.csv("/Users/au301842/enigma_redcap_token.csv",colClasses = "character"))),
  events       = event,
  records      = id,
  forms        = instruments,
  fields       = items
)$data 

}
