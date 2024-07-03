#' Title
#'
#' @param d redcap export data, tibble
#'
#' @return tibble
#' @export
#'
#' @examples
#' d <- date_api_export(token)
date_api_export_prep <- function(d) {
  d_mod <- d |>
    # Defining variable for next visit
    dplyr::mutate(eos_next_book = as.POSIXct(ifelse(is.na(visit_book12), incl_book3, visit_book12))) |>
    # Filter to only include patients booking after EOS if early out
    # filter(eos_next_book>=eos1) |>
    # Filter to only include patients not completed
    dplyr::filter(eos2 != "Nej" | is.na(eos1) | incl_book3 < eos1) |>
    # Exclude EOS vars
    dplyr::select(-tidyselect::starts_with("eos"))

  splitter <- gsub("^\\d.*|[A-Za-z_]", "", colnames(d_mod)) |>
    stRoke::add_padding(pad = "0") |>
    (\(x){
      paste0("A", x)
    })() |>
    factor()

  d_list <- d_mod |> split.default(f = splitter)

  # select(d_list[[2]],contains("_book"))

  reg <- c(0, 3, 12) * 30
  # Interval range to ensure booked times are within protocol definitions
  reg_range <- data.frame(time1 = reg - 15, time2 = reg + 15)

  df_all <- lapply(2:3, function(i) {
    dplyr::tibble(
      id = d_list[[1]][, 1],
      start = d_list[[i]][, 1],
      room = ifelse(is.na(d_list[[i]][, 2]), d_list[[i]][, 3], d_list[[i]][, 2]),
      time2visit_check = difftime(
        start |> as.character() |> substr(1, 10) |> as.Date(),
        as.Date(d_list[[1]][, 2], format = "%Y-%m-%d %H:%M:%S"),
        units = "days"
      ) |> round(),
      protocol_check = time2visit_check %in% seq(reg_range[i, 1], reg_range[i, 2]) &
        !is.na(time2visit_check),
      name = paste(gsub("[A0]", "", names(d_list)[i]), "mdr")
    )
  }) |> dplyr::bind_rows() #|>
  # Filter to only include bookings after current date (include previous five days)
  # No filtering to allow all in calendar
  # dplyr::filter((start>lubridate::ymd_hms(lubridate::now())-90*86400 | is.na(start)&!protocol_check)) |>
  # Only include the first coming visit
  # dplyr::filter(!duplicated(id))
  # Exclude missings (in opposition to the above as older appointments are kept)
  # dplyr::filter(!is.na(start))


  df_all
}
