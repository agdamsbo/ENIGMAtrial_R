## gtsummary examples

tbl_summary(mtcars,
            by = "vs"
)%>%
  add_overall() %>%
  add_n()%>%
  add_p()%>%
  as_gt() %>%
  # modify with gt functions
  gt::tab_header("Table One") %>%
  gt::tab_spanner(
    label = "vs",
    columns = c("stat_1","stat_2")
  ) %>%
  gt::tab_options(
    table.font.size = "small",
    data_row.padding = gt::px(1))
