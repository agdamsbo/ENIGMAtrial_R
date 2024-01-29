# Test index, percentile and ci calculations from raw scores exported from REDCap server

## RBANS index conversion
# source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/index_from_raw.R")

# source("src/index_from_raw.R")

## TABLE LOOKUPS
### Requires data to be in dta

rbans_clean <- function(data){
  data[!apply(apply(select(data, ends_with("_rs")),1,is.na),2,any),]
}

dta <- dta |> rbans_clean()

# dta <- dplyr::filter(dta, dta$record_id != "118")

df <-
  cbind(
    cognitive.index.lookup::index_from_raw(
      dta,
      indx = cognitive.index.lookup::index_table,
      version.col = "urbans_version",
      age.col = "rbans_age",
      raw_columns = names(select(dta, ends_with("_rs")))
    ),
    redcap_event_name = dta$redcap_event_name
  ) %>%
  "colnames<-"(c("record_id", colnames(cbind(
    select(dta, ends_with("_is")),
    select(dta, ends_with("_ci")),
    select(dta, ends_with("_per"))
  )),"version", "redcap_event_name"))

sel1 <- colnames(select(df, ends_with("_per")))
for (i in sel1) {
  df[, i] <- if_else(df[, i] %in% c("> 99.9"), "99.95",
    if_else(df[, i] %in% c("< 0.1", "<0.1", "< 0,1", "<0,1"), "0.05",
      df[, i]
    )
  )
  ## Using the dplyr::if_else for a more stringent vectorisation
}

## Spliting CIs in lower and upper
loups <- c()
for (i in 1:nrow(df)) {
  # i=34
  cis <- c()
  for (j in colnames(select(df, ends_with("_ci")))) {
    # j="rbans_a_ci"
    cis <- c(cis, unlist(strsplit(df[i, j], split = "[-]")))
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
