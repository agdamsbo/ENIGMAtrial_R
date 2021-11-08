redcap_api_export<-function(id=NULL,fld_lst,reduced=FALSE){
# Current approach only works for non-repeating instruments

  library(REDCapR)
  library(tidyverse)

  fields_vec<-c()
  for (i in 1:length(fld_lst)){
    fields_vec<-c(fields_vec,fld_lst[[i]])
  }
  
  fields<-c("record_id",unique(fields_vec))
  events<-names(fld_lst)
  
col_types <- readr::cols(
  record_id = col_double(),
  redcap_event_name = col_character(),
  redcap_repeat_instrument = col_logical(),
  redcap_repeat_instance = col_logical()
)

d <- redcap_read(
    redcap_uri   = "https://redcap.au.dk/api/",
    records_collapsed = id,
    token        = names(suppressWarnings(read.csv("/Users/au301842/enigma_redcap_token.csv",colClasses = "character"))),
    fields       = fields,
    col_types    = col_types
  )$data

if (!is.null(events)){
  d <- d %>% select(.,matches(c("redcap_event_name",fields))) %>% 
    filter(., redcap_event_name %in% events )
}

d<-split(d,d$redcap_event_name)

for (i in 1:length(d)){
  d[[i]]<-d[[i]] %>% select(.,matches(c("record_id",fld_lst[names(fld_lst)==names(d)[i]][[1]])))  
}

if (reduced==TRUE){
  d <- d %>% reduce(full_join,by="record_id")
}

return(d)
}
