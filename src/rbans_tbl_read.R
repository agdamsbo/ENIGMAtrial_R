# Loading tables
source("src/list_tables.R")

index_tables<-list_tables(list.files("index", pattern="*.xlsx", full.names=TRUE))

# Formatting
source("src/interval_extension.R")

index_tables$index_scale_total$scale_total<-interval_extension(index_tables$index_scale_total$scale_total)


# Each element in list should be exported to seperate excel workbook, not to require this function each time.
