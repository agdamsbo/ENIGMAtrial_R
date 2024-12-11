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
#' enigma_calendar_update(allow.stops = TRUE, skip2 = TRUE)
#' enigma_calendar_update(allow.stops = FALSE)
enigma_calendar_update <- function(token = keyring::key_get("enigma_api_key"),
                                   allow.stops = TRUE,
                                   skip1 = TRUE,
                                   skip2 = TRUE) {
  
  # browser()
  df_all <- date_api_export(token) |>
    date_api_export_prep() |>
    dplyr::filter(!is.na(start))

  errors <- apply(is.na(df_all[c(2,4)]), 1, any) |
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
    dplyr::select(-tidyselect::ends_with("check")) |>
    dplyr::mutate(name = gsub(" ", "", name),
                  event = glue::glue("{id}_{name}"))

  ## =============================================================================
  ## Export spreadsheet with assessors on assigned
  ## =============================================================================

  output_folder <- "/Users/au301842/ENIGMAtrial_R/output/kontrol"
  
  #
  # Format for nice printing
  Sys.setlocale("LC_TIME", "da_DK.UTF-8")

  df_out <- df_all |>
    dplyr::arrange(start) |>
    dplyr::filter(
      start < Sys.Date() + lubridate::days(85),
      start >= Sys.Date()
    ) |>
    # dplyr::left_join(dplyr::transmute(filled_file, id, assessor, name = kontrol),
    #   by = join_by(id, name)
    # ) |>
    # mutate(
    #   changes = if_else(start != tid, "ÆNDRET", "samme")
    # ) |>
    # Remove old tid
    # select(-tid) |>
    # Setting new tid
    dplyr::rename(tid = start)

  # Joins the filled file with the original. Keeps original time stamps

  file_path <- paste0(
    output_folder, "/",
    format(as.POSIXct(Sys.Date()),
      format = "%Y%m%d"
    ),
    "_kontroller.ods"
  )

  df_out |>
    transmute(event,tid, id,
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


  filled_new <- list.files(path = output_folder, full.names = TRUE,pattern = "kontroller_f")

  filled_file <- readODS::read_ods(filled_new[length(filled_new)])
  
  filled_up <- filled_file |> 
    dplyr::rename(record_id="id") |> 
    dplyr::mutate(redcap_event_name=dplyr::case_match(kontrol,
                                                      "3mdr"~"inclusion_arm_1",
                                                      "12mdr"~"3_months_arm_1"))
  
  ## Uploading new assessor allocations
  dplyr::bind_rows(filled_up |> 
                     dplyr::filter(kontrol=="3mdr") |> 
                     dplyr::select(record_id,redcap_event_name,assessor) |> 
                     dplyr::rename(incl_assessor=assessor),
                   filled_up |> 
                     dplyr::filter(kontrol=="12mdr") |> 
                     dplyr::select(record_id,redcap_event_name,assessor) |> 
                     dplyr::rename(visit_assessor=assessor)) |>
                     REDCapR::redcap_write(redcap_uri = "https://redcap.au.dk/api/", token = token)
  
  f_nested <- dplyr::full_join(df_all,
    # Time is kept to remove assessor name on time-changes to alert
    filled_file |>
      dplyr::transmute(event, assessor),
    by = c("event","assessor")
  )|>
    dplyr::group_by(event) |>
    tidyr::nest() 

  # Keep latest assessor entry only (all other changes are discarded from spreadsheet)
  f <- f_nested |> 
    dplyr::mutate(
      data = dplyr::if_else(nrow(purrr::pluck(data, 1)) > 1,
                            purrr::pluck(data, 1) |> 
                              (\(.x){
                                d <- as.data.frame(.x)
                                out <- d[1,]
                                out[["assessor"]]<- d[2,"assessor"]
                                dplyr::as_tibble(out)
                              })(),
                            purrr::pluck(data, 1) |> dplyr::slice(1)
      )
    ) |> 
    tidyr::unnest(cols = c(data)) |> 
    dplyr::ungroup()

  obs <- f |>
    dplyr::filter(
      start > Sys.time(),
      start < Sys.time() + lubridate::days(60),
      is.na(assessor)
    ) |>
    dplyr::arrange(start)
  
  if (nrow(obs)>0){
    print(obs)
    
    print("The following IDs are missing assessor for their next appointment, which is soon coming up.")
  }
    

  # Mutates and joins for better labelling
  df_cal <- f |> dplyr::mutate(
    name2 = dplyr::if_else(!is.na(assessor),
      paste0(name, " [", toupper(assessor), "]"),
      NA
    ),
    label = dplyr::if_else(!is.na(name2), name2, name),
    room_short = project.aid::str_extract(room, pattern = "\\d+$"),
    label = dplyr::if_else(is.na(room_short), label, glue::glue("{label} ({room_short})"))
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
    calendar::ic_write(file = "enigma_control.ics",
                       zulu=FALSE)

  # Commit and push GIT

  git_commit_push(f.path = "enigma_control.ics", c.message = paste("calendar update", Sys.Date()))
}
