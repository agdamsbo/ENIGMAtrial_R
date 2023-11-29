path <- "/Users/au301842/Downloads/ENIGMA-MROversigtTilRegnska_DATA_2023-10-06_2300.csv"

ds <- read.csv(path)

readRenviron("/Users/au301842/ENIGMAtrial_R/.Renviron")

token <- Sys.getenv('ENIGMA_REDCAP_API')
uri <- Sys.getenv('ENIGMA_REDCAP_URI')

# ds <- ds[,!grepl("^mr_",names(ds))]

# fields <- sub("___[0-9]$","",names(ds)) |> unique()
fields <- names(ds)

fields <- fields[!grepl("redcap_",fields)]

fields <- unique(gsub("___[0-9]","",fields))

ids <- unique(ds$record_id)

ls <- REDCapCAST::read_redcap_tables(uri,token,records = ids, fields = fields)

ds_clean <- redcap_wider(ls)

# Function to remove row if all fields are NA
all.na.omit <- function(ds){
  fil <- !apply(is.na(ds),1,all)
  ds[fil,]
}

ds_clean <- ds_clean[(ds_clean$mr_24h_perf=="Ja"|ds_clean$mr_12m_perf=="Ja"),] |> all.na.omit()

ds_exp <- ds_clean |> dplyr::select(record_id, resist_id, incl_date, dplyr::ends_with("_perf"))

openxlsx::write.xlsx(ds_exp,paste0(unlist(strsplitx(path,split = "ENIGMA"))[1],"MR_overblik",Sys.Date(),".xlsx"),
          rowNames = FALSE)

