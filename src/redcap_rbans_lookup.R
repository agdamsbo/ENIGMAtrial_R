# Test index, percentile and ci calculations from raw scores exported from REDCap server

## RBANS index conversion
# source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/index_from_raw.R")

# source("src/index_from_raw.R")

## TABLE LOOKUPS
### Requires data to be in dta

rbans_clean <- function(data){
  data[!apply(apply(select(data, ends_with("_rs")),1,is.na),2,any),] |> dplyr::tibble()
}

dta <- dta |> rbans_clean()

# dta <- dplyr::filter(dta, dta$record_id != "118")

df <- dta |> 
    cognitive.index.lookup::index_from_raw(
      indx = cognitive.index.lookup::index_table,
      version.col = "urbans_version",
      age.col = "rbans_age",
      raw_columns = names(select(dta, ends_with("_rs")))
    ) |> #names() |> dput()
  dplyr::select(tidyselect::all_of(c("record_id", "redcap_event_name", "urbans_version",
                                     "test_a_is_immediate", "test_b_is_visuospatial", "test_c_is_verbal", 
                                     "test_d_is_attention", "test_e_is_delayed", "test_i_is_total", 
                                     "test_a_ci", "test_b_ci", "test_c_ci", "test_d_ci", "test_e_ci", 
                                     "test_i_ci", "test_a_per", "test_b_per", "test_c_per", "test_d_per", 
                                     "test_e_per", "test_i_per"))) |> 
    setNames(c("record_id", "redcap_event_name", "urbans_version",
               "rbans_a_is", "rbans_b_is", "rbans_c_is", 
               "rbans_d_is", "rbans_e_is", "rbans_i_is", 
               "rbans_a_ci", "rbans_b_ci", "rbans_c_ci", "rbans_d_ci", "rbans_e_ci", 
               "rbans_i_ci", "rbans_a_per", "rbans_b_per", "rbans_c_per", "rbans_d_per", 
               "rbans_e_per", "rbans_i_per"))

# sel1 <- colnames(select(df, ends_with("_per")))
# for (i in sel1) {
#   df[, i] <- if_else(df[, i] %in% c("> 99.9"), "99.95",
#     if_else(df[, i] %in% c("< 0.1", "<0.1", "< 0,1", "<0,1"), "0.05",
#       df[, i]
#     )
#   )
#   ## Using the dplyr::if_else for a more stringent vectorisation
# }

## Spliting CIs in lower and upper
loups <- c()
for (i in seq_len(nrow(df))) {
  # i=1
  cis <- c()
  for (j in colnames(dplyr::select(df, dplyr::ends_with("_ci")))) {
    # j="rbans_a_ci"
    cis <- c(cis, unlist(strsplit(df[i, j][[1]], split = "[-]")))
  }
  loups <- c(loups, c(df$record_id[i], cis))
}
loups <- data.frame(matrix(loups, ncol = 13, byrow = TRUE))

### Naming and merging
cnms <- c()
for (k in colnames(select(df, ends_with("_ci")))) {
  # j="rbans_a_ci"
  stp <- unlist(strsplit(k, split = "[_]"))[-3]
  cnms <- c(cnms, paste0(paste(stp, collapse = "_"), "_", c("lo", "up")))
}

df <- merge(df, loups %>%
  "colnames<-"(c("record_id", cnms)) %>%
  dplyr::mutate(record_id = as.numeric(record_id)))

## Type conversion

df <- df %>%
  dplyr::mutate(dplyr::across(
    .cols = dplyr::all_of(colnames(dplyr::select(df, c(
      "record_id",
      dplyr::ends_with(c("_is", "_per", "_lo", "_up"))
    )))), ## Selecting variables to include, keeping "_ci" and event_name out.
    ~ as.numeric(.)
  )) ## Converting types
