## Merge with "redcap_api_export.R" function??

redcap_api_export_short<-function(event=NULL,id=NULL,instruments=NULL,items = "record_id"){
  require(REDCapR)
  # event = specific event desired
  # id    = patient IDs to export
  # instruments = instruments
  # items = extra items in addition to instruments
  
redcap_read_oneshot(
  redcap_uri   = "https://redcap.au.dk/api/",
  token        = keyring::key_get("enigma_api_key"),
  events       = event,
  records      = id,
  forms        = instruments,
  fields       = items
)$data 

}
