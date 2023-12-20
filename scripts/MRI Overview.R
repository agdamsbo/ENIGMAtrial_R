# path <- "/Users/au301842/Downloads/ENIGMA-MROversigtTilRegnska_DATA_2023-12-05_1431.csv"
#
# ds <- read.csv(path)

# ds <- ds[,!grepl("^mr_",names(ds))]

# fields <- sub("___[0-9]$","",names(ds)) |> unique()
# fields <- names(ds)
#
# fields <- fields[!grepl("redcap_", fields)]
#
# fields <- unique(gsub("___[0-9]", "", fields))

# ids <- unique(ds$record_id)

# Function to remove row if all fields are NA
# all.na.omit <- function(ds) {
#   fil <- !apply(is.na(ds), 1, all)
#   ds[fil, ]
# }

readRenviron("/Users/au301842/ENIGMAtrial_R/.Renviron")

REDCapCAST::read_redcap_tables(uri = "https://redcap.au.dk/api/", token = Sys.getenv("ENIGMA_REDCAP_API"), fields = c(
  "incl_date", "record_id", "resist_id", "incl_mr", "mr_reg",
  "mr_24h_perf", "mr_24h_prot", "mr_24h_corr", "mr_12m_perf"
)) |>
  REDCapCAST::redcap_wider() |>
  dplyr::filter((mr_24h_perf == "Ja" | mr_12m_perf == "Ja")) |>
  dplyr::select(record_id, resist_id, incl_date, dplyr::ends_with("_perf")) |>
  openxlsx::write.xlsx(paste0("/Users/au301842/Downloads/MR_overblik_a", Sys.Date(), ".xlsx"),
    rowNames = FALSE
  )
