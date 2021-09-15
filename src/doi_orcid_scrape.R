doi_orcid_scrape<-function(id){
  # Provide ORCIDs to return all available unique DOIs
  # based on https://www.pauloldham.net/introduction-to-orcid-with-rorcid/
  library(rorcid)
  orcid_auth()
  
  dois<-c()
  for(i in 1:length(id)){
    dsc_works <- rorcid::orcid_works(id[i])
    
    my_works_data <- dsc_works %>%
      purrr::map_dfr(pluck, "works") %>%
      janitor::clean_names() %>%
      dplyr::mutate(created_date_value = anytime::anydate(created_date_value/1000))
    
    ids_raw <- my_works_data %>%
      select(external_ids_external_id)
    
    ids_clean <- ids_raw %>%
      map(., compact) %>% 
      map_df(bind_rows) %>% 
      janitor::clean_names()
    
    doi_vec <- ids_clean %>% 
      filter(external_id_type == "doi") %>% 
      select(external_id_value)
    
    dois<-c(dois,doi_vec[[1]])
  }
  return(unique(dois))
}
