# 28.1.22 Workflow rewritten to include one index file instead of several excel-workbooks.
# This script and functions imports the work books and collects all to one .csv file.
# Aim is to host a shiny app for easy index score look-up.

# Loading tables
source("src/list_tables.R")

index_tables<-list_tables(list.files("index", pattern="*.xlsx", full.names=TRUE))

# Formatting
source("src/interval_extension.R")

index_tables$index_total$scale_total<-data.frame(interval_extension(index_tables$index_total$scale_total),version=NA)
## A "version" column is added only to match number of columns later

## a - immediate
## b - visuospatial
## c - verbal
## d - attention
## e - delayed

## Here follow an export of a collected csv index file

cln<-c("grp","raw", "index", "pct90", "pct95", "perc", "ver")
ds<-data.frame(matrix(ncol=length(cln)))
colnames(ds)<-cln

for (i in names(index_tables)){
  # i=names(index_tables)[7]
  for (j in names("[["(index_tables,i))){ ## Sub-subsetting
    ss<-data.frame(grp=paste0(i,"_",j),index_tables[[i]][[j]]) ## Including new variables for later subsetting
    colnames(ss)<-cln ## Defining new colnames.
    ds<-rbind(ds,ss)
  }
}

write.csv(ds[-1,],"/Users/au301842/ENIGMAtrial_R/index/index.csv",row.names = F)
