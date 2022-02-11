# Loadning tables

# source("src/rbans_tbl_read.R")

# 28.1.22 Workflow rewritten to include one indexfile instead of several excel-workbooks.

index<-read.csv("/Users/au301842/ENIGMAtrial_R/index/index.csv")

index_ls<-split(index,factor(index$grp))

# Loading data
# source("src/enigma_age_calc.R")

source("src/redcap_api_export.R")

## A problem will occur when exporting from to visits on the same subject
library(daDoctoR)
library(dplyr)
library(purrr)

d<-redcap_api_export(id=id,fld_lst = field_list,reduced = TRUE)

# Conversion
source("src/index_from_raw.R")

df<-index_from_raw(dta = select(d,c("record_id",ends_with("_rs"))),version = d$urbans_version,age=d$age,raw_columns=names(select(d,ends_with("_rs"))))

# Clean-up
source("src/remove_all_but.R")
remove_all_but(d,df)
