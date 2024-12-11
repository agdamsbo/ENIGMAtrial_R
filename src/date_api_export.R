date_api_export <- function(token) {
  REDCapCAST::read_redcap_tables(
    uri = "https://redcap.au.dk/api/",
    token = token,
    fields = c(
      "record_id",
      "incl_date",
      "incl_book3",
      "incl_room3",
      "incl_other3", 
      "incl_assessor",
      "visit_assessor",
      "visit_book12",
      "visit_room12",
      "visit_other12",
      "eos1",
      "eos2"
    ),
    raw_or_label = "label"
  ) |> REDCapCAST::redcap_wider()
}


# d <- REDCapCAST::read_redcap_tables(
#   uri   = "https://redcap.au.dk/api/",
#   token        = token,
#   fields       = c(
#     "record_id",
#     "incl_date",
#     "incl_book3",
#     "incl_room3",
#     "incl_other3",
#     "visit_book12",
#     "visit_room12",
#     "visit_other12",
#     "eos1",
#     "eos2"
#   ),
#   raw_or_label = "label"
# ) |> REDCapCAST::redcap_wider()

# d <- redcap_read(
#     redcap_uri   = "https://redcap.au.dk/api/",
#     token        = token,
#     fields       = fields,
#     # col_types    = col_types,
#     raw_or_label = "label"
#   )$data
