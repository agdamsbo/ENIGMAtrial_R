# Background

# Ref: https://ciakovx.github.io/rorcid.html

# Ref: https://www.pauloldham.net/introduction-to-orcid-with-rorcid/

library(rorcid)
library(usethis)
library(tidyverse)
library(anytime)
library(lubridate)
library(janitor)
library(listviewer)
library(rcrossref)


# ORCID scraping for DSC

# source("src/orcid_keyfile.R")

# Auth method 1
orcid_auth()

# Data draw

source("src/dsc_members.R")

source("src/doi_orcid_scrape.R")

dsc_dois<-doi_orcid_scrape(dsc_orcids)

crossref_dsc<-rcrossref::cr_works(dois=dsc_dois)

crossref_dsc_clean<- crossref_dsc$data %>% 
  janitor::clean_names()

crossref_dsc_clean %>% 
  count(container_title, sort = TRUE)

