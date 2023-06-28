## =============================================================================
## On-machine run setup
## =============================================================================

# See: https://anderfernandez.com/en/blog/how-to-automate-r-scripts-on-windows-and-mac/
# library(cronR)
# path <- "/Users/au301842/ENIGMAtrial_R/scripts/Modification.R"
# cmd <- cron_rscript(path)
# cron_add(command = cmd, frequency = 'daily', at = "10AM",
#          id = 'enigma_mods', description = 'ENNIGMA data modification', tags = c('enigma', 'r'))

## =============================================================================
## Abroad mode: Only run when on VPN
## =============================================================================

vpn_on_check <- function(command="scutil --proxy"){
# Source: https://superuser.com/a/1206006
# This function gives "  ProxyAutoDiscoveryEnable : 0" when connected to proxy

proxy_inf <- system(command, intern = T)

# Discussed here: https://stackoverflow.com/questions/7963898/extracting-the-last-n-characters-from-a-string-in-r
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

# Gives true if VPN is on
substrRight(proxy_inf[4],1)=="0"
}
abroad=FALSE

# This is a poor mans test, but it does the job for now (!)
if (abroad) {
  if (!vpn_on_check()) stop("Assuming not connected to VPN!")
} else message("Go on on regular connection at home!")

## =============================================================================
## Helper functions when running as script
## =============================================================================

source("https://gist.githubusercontent.com/agdamsbo/e3b486b32c614cbea5b971c333740688/raw/6b00696b7aa7354a5e006de2ea4181776d576fd7/check.packages.r")

# Determine loaded packages after a run of the given (open) file
# fname <- rstudioapi::getSourceEditorContext()$path
# source(fname)
# names(sessionInfo()[["otherPkgs"]])

# Usage example
packages<-c("REDCapR", "dplyr", "lubridate")
check.packages(packages)

## Automated data modification and upload

# token=keyring::key_get("enigma_api_key")

# Necessary to load .renviron file to run in cron
readRenviron("/Users/au301842/ENIGMAtrial_R/.Renviron")

token <- Sys.getenv('ENIGMA_REDCAP_API')
uri <- Sys.getenv('ENIGMA_REDCAP_URI')

# Changed from using library(keyring) to .Renviron to use with github actions

## =============================================================================
## Libraries
## =============================================================================

# require(REDCapR)
# require(dplyr)
# require(lubridate)

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
# source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_upload_inclusion.R")

# Clean up function
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/remove_all_but.R")
remove_all_but(token,uri,remove_all_but)


## =============================================================================
## 3 months data modification
## =============================================================================

### Modifies 3 months RBANS data

all_ids_3=FALSE
# all_ids_3 <- TRUE

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
