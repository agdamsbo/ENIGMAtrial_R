# 28.1.22 Workflow rewritten to include one index file instead of several excel-workbooks.
# This script and functions imports the work books and collects all to one .csv file.
# Aim is to host a shiny app for easy index score look-up.
# 01.11.22 BUG Wrong A/B tables. Found in 60-69 delayed. Check all!

# Loading tables
source("src/list_tables.R")

index_tables<-list_tables(list.files("index", pattern="*.xlsx", full.names=TRUE))

# index_tables<-list_tables(list.files("/Users/au301842/Library/CloudStorage/OneDrive-Personligt/Research/ENIGMA/RBANS/index files", pattern="*.xlsx", full.names=TRUE))


# Formatting
source("src/interval_extension.R")

tot.tbl<-names(index_tables)[grepl("total",names(index_tables))]

index_tables[[tot.tbl]][[1]]<-data.frame(interval_extension(index_tables[[tot.tbl]][[1]]),version=NA)
## A "version" column is added only to match number of columns later

## a - immediate
## b - visuospatial
## c - verbal
## d - attention
## e - delayed

## Here follow an export of a collected csv index file

cln<-c("grp","raw", "index", "pct90", "pct95", "perc", "ver")

for (i in names(index_tables)){
  # i=names(index_tables)[7]
  for (j in names("[["(index_tables,i))){ ## Sub-subsetting
    index_tables[[i]][[j]]<-data.frame(grp=paste0(i,"_",j),index_tables[[i]][[j]]) ## Including new variables for later subsetting
    colnames(index_tables[[i]][[j]])<-cln ## Defining new colnames.
  }
}

ds <- do.call(rbind,append(do.call(rbind,index_tables[1:6]),index_tables[[7]]))

write.csv(ds,"/Users/au301842/ENIGMAtrial_R/index/index.csv",row.names = F)
