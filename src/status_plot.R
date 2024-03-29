# Visuals

status_plot <- function(data, num = "record_id", incl_date = "incl_date", eos_date = NULL, correct_today = TRUE) {
  ds <- dplyr::select(data, num, incl_date, eos_date)

  # ds <- ds |> dplyr::arrange(-dplyr::desc(num))

  if (correct_today) {
    ds[, incl_date][ds[, num] == max(ds[, num])] <- lubridate::today()
  }

  trend_line <- data.frame(
    number = c(1, as.numeric(difftime(ds[, incl_date][nrow(ds)], ds[, incl_date][1], units = "weeks"))),
    date = c(ds[, incl_date][1], ds[, incl_date][nrow(ds)])
  )

  trend_line_eos <- data.frame(
    number = trend_line[1],
    date = (trend_line[2] + 365)
  )

  names(ds)[1] <- "num"




  if (!is.null(eos_date)) {
    dt <- ds[is.na(ds$eos_date), ]
    dt$non_eeos <- as.numeric(seq(dt$num))

    ggplot2::ggplot(data = dt, ggplot2::aes(x = incl_date, y = non_eeos)) +
      ggplot2::geom_line(color = "#00AFBB", size = 2) +
      ggplot2::scale_x_date(date_breaks = "1 month", date_labels = "%b/%y") +
      ggplot2::xlab("Inclusion date") +
      ggplot2::ylab("Number of included patients") +
      ggplot2::geom_line(data = trend_line_eos, ggplot2::aes(x = date, y = number))
  } else {
    ggplot2::ggplot(ds, ggplot2::aes(x = incl_date, y = num)) +
      ggplot2::geom_line(color = "#00AFBB", size = 2) +
      ggplot2::scale_x_date(date_breaks = "2 months", date_labels = "%b/%y") +
      ggplot2::xlab("Inclusion date") +
      ggplot2::ylab("Number of included patients") +
      ggplot2::geom_line(data = trend_line, ggplot2::aes(x = date, y = number))
  }
}
