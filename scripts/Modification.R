## Automated data modification and upload

token=names(suppressWarnings(read.csv("/Users/au301842/enigma_redcap_token.csv",colClasses = "character")))
uri="https://redcap.au.dk/api/"

## =============================================================================
## Libraries
## =============================================================================

require(REDCapR)
require(dplyr)
require(lubridate)

## =============================================================================
## Inclusion data upload (mostly)
## =============================================================================

### Modifies the following
### - kon
### - dob
### - age + rbans_age
### - incl_since_start
### - incl_ratio
### - incl_data_mod

# source("src/redcap_upload_inclusion.R")
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_upload_inclusion.R")


# Clean up function
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/remove_all_but.R")
remove_all_but(token,uri,remove_all_but)


## =============================================================================
## 3 months data modification
## =============================================================================

### Modifies 3 months RBANS data

all_ids_3=TRUE

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_upload_rbans3.R")
remove_all_but(token,uri,remove_all_but)

## =============================================================================
## 12 months data modification
## =============================================================================

### Modifies 12 months RBANS data and generates basic RBANS conclusion

all_ids_12=TRUE

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_upload_rbans12.R")

## =============================================================================
## Cleans environment
## =============================================================================

rm(list=ls(pos=1))