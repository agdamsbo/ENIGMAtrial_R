## Automated data modification and upload

token=names(suppressWarnings(read.csv("/Users/au301842/enigma_redcap_token.csv",colClasses = "character")))
uri="https://redcap.au.dk/api/"

### Libraries
require(REDCapR)
require(dplyr)
require(daDoctoR)
require(lubridate)

## Inclusion data upload (mostly)
### Modifies the following
### - kon
### - dob
### - age + rbans_age
### - incl_since_start
### - incl_ratio
### - incl_data_mod

source("src/redcap_data_upload.R")
# source("")


## 3 months data modification
### Modifies 3 months RBANS data

# source("src/redcap_rbans3_upload.R")

## 12 months data modification
### Modifies 12 months RBANS data and generates basic RBANS conclusion
