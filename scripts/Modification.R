## =============================================================================
## On-machine run
## =============================================================================

# See: https://anderfernandez.com/en/blog/how-to-automate-r-scripts-on-windows-and-mac/
# library(cronR)
# path <- "/Users/au301842/ENIGMAtrial_R/scripts/Modification.R"
# cmd <- cron_rscript(path)
# cron_add(command = cmd, frequency = 'daily', at = "10AM",
#          id = 'enigma_mods', description = 'ENNIGMA data modification', tags = c('enigma', 'r'))


## Automated data modification and upload

token=keyring::key_get("enigma_api_key")
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
### - kon DEPRECATED, calculated in REDCap
### - dob DEPRECATED, calculated in REDCap
### - age DEPRECATED, calculated in REDCap
### - rbans_age DEPRECATED, calculated in REDCap
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

all_ids_3=FALSE
all_ids_3 <- TRUE

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_upload_rbans3.R")
remove_all_but(token,uri,remove_all_but)

## =============================================================================
## 12 months data modification
## =============================================================================

### Modifies 12 months RBANS data and generates basic RBANS conclusion

## The look-up function is not working. The index has been fixed. Why??
all_ids_12=FALSE

# all_ids_12 <- TRUE

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_upload_rbans12.R")

## =============================================================================
## Cleans environment
## =============================================================================

rm(list=ls(pos=1))
