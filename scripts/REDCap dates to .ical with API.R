## =============================================================================
## Getting data from REDCap
## =============================================================================

# REDCap data export/import script
# token <- keyring::key_get("enigma_api_key")
library(calendar)
library(tidyverse)
source("src/date_api_export.R")
source("src/date_api_export_prep.R")
source("src/convert_ical.R")
source("src/enigma_git_push.R")


#' Title
#'
#' @param token
#' @param allow.stops
#'
#' @return
#' @export
#'
#' @examples
#' enigma_calendar_update(allow.stops = TRUE, skip2 = FALSE)
#' enigma_calendar_update(allow.stops = FALSE)
enigma_calendar_update <- function(token = keyring::key_get("enigma_api_key"),
                                   allow.stops = TRUE,
                                   skip1 = TRUE,
                                   skip2 = TRUE) {
  df_all <- date_api_export(token) |> 
    date_api_export_prep()|> 
    dplyr::filter(!is.na(start))

  errors <- apply(is.na(df_all[2:3]), 1, any) | 
    !df_all$protocol_check

  df_error <- df_all |> dplyr::filter(start > lubridate::now(), errors)


  if (nrow(df_error) > 1) {
    print(df_error)
    if (allow.stops && !skip1) {
      stop("Check lige at booking-oplysningerne passer for disse")
    } else {
      print("Check lige at booking-oplysningerne passer for disse")
    }
  }

  df_all <- df_all |> 
    dplyr::select(-tidyselect::ends_with("check"))|>
    dplyr::mutate(name = gsub(" ", "", name)) 

  ## =============================================================================
  ## Export spreadsheet with assessors on assigned
  ## =============================================================================

  output_folder <- "/Users/au301842/ENIGMAtrial_R/output/kontrol"

  files_filter <- function(folder.path, filter.by, full.names = TRUE) {
    # List files in folder
    files <- list.files(path = folder.path, full.names = full.names)

    # Gets names of all files ending on kotroller_f (filled)
    files[grepl(filter.by, files)]
  }

  filled <- files_filter(output_folder, "kontroller_f")

  # Loads the last (newest) filled spreadsheet to include new changes
  filled_file <- filled |>
    purrr::map(readODS::read_ods) |>
    purrr::map(na.omit) |>
    purrr::reduce(dplyr::full_join) |>
    dplyr::group_by(id, kontrol) |>
    tidyr::nest() |>
    dplyr::mutate(data = dplyr::if_else(nrow(purrr::pluck(data, 1)) > 1,
      purrr::pluck(data, 1)[nrow(purrr::pluck(data, 1)), ],
      purrr::pluck(data, 1)[1, ]
    ),
    kontrol = gsub(" ", "", kontrol)) |>
    tidyr::unnest(cols = c(data)) |>
    dplyr::ungroup()


  #
  # Format for nice printing
  Sys.setlocale("LC_TIME", "da_DK.UTF-8")

  df_out <- df_all |>
    dplyr::arrange(start) |>
    dplyr::filter(
      start < Sys.Date() + lubridate::days(85),
      start >= Sys.Date()
    ) |>
    dplyr::left_join(dplyr::transmute(filled_file, id, assessor, name = kontrol),
      by = join_by(id, name)
    ) |>
    # mutate(
    #   changes = if_else(start != tid, "ÆNDRET", "samme")
    # ) |>
    # Remove old tid
    # select(-tid) |>
    # Setting new tid
    rename(tid = start)

  # Joins the filled file with the original. Keeps original time stamps

  file_path <- paste0(
    output_folder, "/",
    format(as.POSIXct(Sys.Date()),
      format = "%Y%m%d"
    ),
    "_kontroller.ods"
  )

  df_out |>
    transmute(tid, id,
      kontrol = name,
      assessor = ifelse(!is.na(assessor), assessor, "")
    ) |>
    readODS::write_ods(path = file_path)

  if (allow.stops && !skip2) {
    system2("open", output_folder)
    system2("open", file_path)

    stop("PART 2: fill file and continue manually!")
  }
  ## =============================================================================
  ## Including assessor
  ## =============================================================================


  filled_new <- files_filter(output_folder, "kontroller_f")

  # Loads the last (newest) filled spreadsheet to include new changes
  if (!identical(filled_new, filled)) {
    filled_file <- filled_new |>
      purrr::map(readODS::read_ods) |>
      purrr::map(na.omit) |>
      purrr::reduce(dplyr::full_join) |>
      dplyr::group_by(id, kontrol) |>
      tidyr::nest() |>
      dplyr::mutate(
        data = dplyr::if_else(nrow(purrr::pluck(data, 1)) > 1,
          purrr::pluck(data, 1)[nrow(purrr::pluck(data, 1)), ],
          purrr::pluck(data, 1)[1, ]
        ),
        kontrol = gsub(" ", "", kontrol)
      ) |>
      tidyr::unnest(cols = c(data)) |>
      dplyr::ungroup()
  }

  # all <- filled |> purrr::map(readODS::read_ods) |> purrr::reduce(dplyr::full_join)

  # Joins the filled file with the original. Keeps original time stamps


  f <- dplyr::left_join(df_all,
    # Time is kept to remove assessor name on time-changes to alert
    filled_file |>
      dplyr::transmute(id, name=kontrol,assessor),
    by = c("id", "name")
  )

  f |>
    dplyr::filter(
      start > Sys.time(),
      start < Sys.time() + lubridate::days(60),
      is.na(assessor)
    ) |>
    dplyr::arrange(start) |>
    print()

  print("The following IDs are missing assessor for their next appointment, which is soon coming up.")

  # Mutates and joins for better labelling
  df_cal <- f |> dplyr::mutate(
    name2 = dplyr::if_else(!is.na(assessor),
      paste0(name, " [", toupper(assessor), "]"),
      NA
    ),
    label = dplyr::if_else(!is.na(name2), name2, name),
    room_short = project.aid::str_extract(room,pattern = "\\d+$"),
    label=dplyr::if_else(is.na(room_short),label,glue::glue("{label} ({room_short})"))
    
  ) #|> 
    # Only keeping from the last year as the .ics doesn't sync if its too big.
    # dplyr::filter(start>Sys.Date()-lubridate::years(1))


  # split by ID, keep last for each appointment
  # 
  
  ## =============================================================================
  ## Creating calendar and comitting
  ## =============================================================================

  # Conversion to calendar files (.ics)

  convert_ical(df_cal,
    start = "start",
    id = "id",
    name = "label",
    room = "room"
  )[[2]] |>
    calendar::ic_write(file = "enigma_control.ics")

  # Commit and push GIT

  git_commit_push(f.path = "enigma_control.ics", c.message = paste("calendar update", Sys.Date()))
}
