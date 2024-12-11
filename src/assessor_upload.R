# Upload all assessor allocations for better handling
# 

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
  dplyr::mutate(
    data = dplyr::if_else(nrow(purrr::pluck(data, 1)) > 1,
                          purrr::pluck(data, 1)[nrow(purrr::pluck(data, 1)), ],
                          purrr::pluck(data, 1)[1, ]
    ),
    kontrol = gsub(" ", "", kontrol)
  ) |> 
  tidyr::unnest(cols = c(data)) |> 
  dplyr::ungroup()
  


wide <- filled_file |>
  dplyr::select(id, kontrol, assessor) |>
  tidyr::pivot_wider(id_cols = id, values_from = assessor, names_from = kontrol) |>
  tidyr::unnest(cols = c(`3mdr`, `12mdr`)) |>
  dplyr::rename(
    record_id = "id",
    incl_assessor = "3mdr",
    visit_assessor = "12mdr"
  )

# The first approach is the most straight forward
# dplyr::bind_rows(dplyr::select(wide,record_id,incl_assessor) |> dplyr::mutate(redcap_event_name="inclusion_arm_1"),
#                  dplyr::select(wide,record_id,visit_assessor) |> dplyr::mutate(redcap_event_name="3_months_arm_1")) |>
#   REDCapR::redcap_write(redcap_uri = "https://redcap.au.dk/api/", token = token)

# REDCapR::redcap_write(ds_to_write = dplyr::select(wide,-visit_assessor) |> dplyr::mutate(redcap_event_name="inclusion_arm_1"), redcap_uri = "https://redcap.au.dk/api/", token = token)
# REDCapR::redcap_write(ds_to_write = dplyr::select(wide,-incl_assessor) |> dplyr::mutate(redcap_event_name="3_months_arm_1"), redcap_uri = "https://redcap.au.dk/api/", token = token)

# REDCapR::redcap_read(redcap_uri = "https://redcap.au.dk/api/", token = token,fields = c("record_id","incl_assessor"))$data |> View()
