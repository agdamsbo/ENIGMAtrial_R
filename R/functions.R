#' Get REDCap list with specified fields
#'
#' @param next_id numeric vector of next available ID
#'
#' @return list
#' @examples
#' redcap2list()
redcap2list <- function() {
  REDCapCAST::read_redcap_tables(
    uri = "https://redcap.au.dk/api/",
    token = keyring::key_get("enigma_api_key"),
    fields = c("record_id", "incl_by", "incl_date", "age", "kon", "resist_incl"),
    forms = c(
      "klassifikation_af_primre_stroke",
      "baseline_stroke",
      # "registrering", # To avoid including cpr, fields should be specified individually
      "baseline_nihss",
      "hjde_vgt_og_blodtryk",
      "rygeanamnese",
      "eos"
    )
  )
}

#' Removes IDs with missing raws and calculates age
#'
#' @param data data set
#'
#' @return data.frame
#' @export
rbans_ready <- function(data) {
  data |>
    dplyr::filter(dplyr::if_any(tidyselect::ends_with("_rs"), ~ !is.na(.))) |>
    dplyr::mutate(rbans_age = floor(stRoke::age_calc(dob = readr::parse_date(rbans_dob, format = "%d-%m-%Y"), enddate = rbans_date)))
}

#' Subset and filtered dataset
#'
#' @param data data
#'
#' @return dataset
lost_subjects <- function(data) {
  data |>
    dplyr::filter(eos2 == "Nej") |>
    dplyr::transmute(
      # id = record_id,
      age = age,
      toast = class_toast,
      kon = kon,
      incl_time = as.numeric(difftime(eos1, incl_date, units = "days"))
    )
}

#' Summary table of lost2followups
#'
#' @param data data
#'
#' @return gtsummary table
lost2follow_tbl <- function(data) {
  data |>
    lost_subjects() |>
    gtsummary::tbl_summary(
      by = kon
    )
}

#' Plot lost2followups
#'
#' @param data
#'
#' @return ggplot object
lost2follow_plot <- function(data) {
  data |>
    lost_subjects() |>
    ggplot2::ggplot(ggplot2::aes(x = incl_time, y = kon, color = kon)) +
    ggplot2::geom_violin() +
    ggplot2::geom_boxplot(width = 0.1, outlier.shape = NA) +
    ggplot2::geom_jitter(shape = 16, position = ggplot2::position_jitter()) + 
    ggplot2::scale_x_continuous(breaks=c(0,90,365))+
    ggplot2::theme_minimal(base_size = 18) +
    ggplot2::xlab("Inklusionstid (dage)") +
    ggplot2::ylab(NULL) +
    ggplot2::ggtitle("Deltagere uden fuld opfølgning") +
    ggplot2::theme(legend.position = "none")
}


#' Print gtsummary baseline table
#'
#' @param data wide data set
#'
#' @return gtsummary list object
print_baseline <- function(data) {
  data |>
    dplyr::select(
      age,
      kon,
      civil,
      hypertension,
      diabetes,
      resist_incl,
      nihss_baseline_sum,
      treated_thrombolysis,
      treated_thrombectomy
    ) |>
    dplyr::transmute(
      age = age,
      kon = kon,
      civil = civil == "Bor alene",
      hypertension = hypertension != "Nej",
      diabetes = diabetes != "Nej",
      resist_incl = resist_incl == "Ja",
      nihss = nihss_baseline_sum,
      thrombolysis = treated_thrombolysis == "Ja",
      thrombectomy = treated_thrombectomy == "Ja"
    ) |>
    gtsummary::tbl_summary(
      by = "kon",
      missing = "no",
      label = list(
        age ~ "Alder",
        # kon ~ "Køn",
        civil ~ "Bor alene",
        nihss ~ "NIHSS at admission",
        civil ~ "Living alone",
        resist_incl ~ "RESIST participant",
        thrombolysis ~ "IVT",
        thrombectomy ~ "EVT"
      )
    ) |>
    gtsummary::add_overall()
}

#' Plots inclusion status
#'
#' @param data wide data set
#'
#' @return ggplot2 list object
status_plot <- function(data) {
  ds <- data |> dplyr::transmute(num = record_id, date = incl_date)

  ds[, "date"][ds[, "num"] == max(ds[, "num"])] <- lubridate::today()

  hope_line <- data.frame(
    number = c(1, as.numeric(difftime(ds[, "date"][nrow(ds)], ds[, "date"][1], units = "weeks"))),
    date = c(ds[, "date"][1], ds[, "date"][nrow(ds)])
  )

  ggplot2::ggplot(ds, ggplot2::aes(x = date, y = num)) +
    ggplot2::geom_line(color = "#00AFBB", linewidth = 2) +
    ggplot2::scale_x_date(date_breaks = "2 months", date_labels = "%b/%y") +
    ggplot2::xlab("Inclusion date") +
    ggplot2::ylab("Number of included patients") +
    ggplot2::geom_line(data = hope_line, ggplot2::aes(x = date, y = number))
}


#' Gets next ID
#'
#' @return writes .csv with next id
#' @examples
#' data_status_check()
data_status_check <- function() {
  write.csv(REDCapR::redcap_next_free_record_name(
    redcap_uri = "https://redcap.au.dk/api/",
    token = keyring::key_get("enigma_api_key")
  ), here::here("data/next_id.csv"), row.names = FALSE)
}


#' Create linear model for inclusion prediction based on latest n months inclusion rate
#'
#' @param data wide data
#' @param latest.months number of latest months to base prediction on
#'
#' @return lm object
filtered_model <- function(data, latest.months = 6) {
  data |>
    dplyr::transmute(num = record_id, date = incl_date) |>
    filter(date > lubridate::add_with_rollback(Sys.Date(), months(-latest.months))) |>
    lm(num ~ date, data = _)
}

#' Predict included at given date
#'
#' @param model inclusion rate model
#' @param enddate given date, passed to `lubridate::date()`
#'
#' @return vector of same length as enddate
predict_from_date <- function(model, enddate = "2024-06-01") {
  model |>
    predict(data.frame(date = date(enddate))) |>
    floor()
}

#' Predict the date of the inclusion of a given subject ID
#'
#' @param model inclusion rate model
#' @param sequence date sequence of interest
#' @param endnum the given number of interest
#'
#' @return vector of length 1
predict_from_num <- function(model, sequence, endnum = 150) {
  ## This function is naïve and trusts you. Please live up to that!
  ## It has no checks or security functions.
  ## I tried getting uniroot() to work but to no avail.
  ## https://stackoverflow.com/questions/32040504/regression-logistic-in-r-finding-x-value-predictor-for-a-particular-y-value
  tibble(
    x = sequence,
    y = model |> predict(data.frame(date = date(x))) |> floor()
  ) |>
    filter(y == endnum) |>
    head(1) |>
    select(x) |>
    c()
}

#' Map function to get enddate estimate based on different forecasting models
#'
#' @param data wide data
#' @param basis numeric vector of recent months to base forecast on
#'
#' @return character vector of same length as `basis`
estimate_enddate <- function(data, basis = c(2, 4, 6)) {
  map(basis, function(x) {
    data |>
      filtered_model(latest.months = x) |>
      predict_from_num(sequence = seq(lubridate::today(), (lubridate::today() + years(1)), by = 1)) |>
      purrr::reduce(c)
  }) |> purrr::reduce(c)
}






# rmarkdown::render(here::here("scripts/Fremtidige 12 mdr bookinger.Rmd"),output_file=file.path(here::here('output',paste0(format(Sys.Date(),"%Y%m%d"),'_12mdr_oversigt.pdf'))))


# This works well
# rmarkdown::render(here::here("scripts/fremtidige-bookinger.qmd"),output_file=file.path(here::here('output',paste0(format(Sys.Date(),"%Y%m%d"),'_ENIGMA_booking_oversigt.pdf'))))
