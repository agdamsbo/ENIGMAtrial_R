install.packages("REDCapCAST")

df <- REDCapCAST::easy_redcap(
  project.name = "ENIGMA",
  uri = "https://redcap.au.dk/api/",
  fields = c(
    # record_id benyttes alene som index
    "record_id",
    # Alder og køn
    "age", "kon",
    # Cronical diseases
    "diabetes",
    "hypertension",
    # NIHSS score
    "nihss_baseline_sum",
    # Cognitive scores
    "iq_score",
    "i_score",
    # PA
    "pase_score"
  ),
  events = c("inclusion_arm_1", "3_months_arm_1", "12_months_arm_1"),
  widen.data = TRUE
)

## Example table to show how labels are kept
df |>
  gtsummary::tbl_summary(
    by = kon,
    label = list(
      nihss_baseline_sum = "NIHSS",
      iq_score = "IQCODE"
    )
  ) |> 
  gtsummary::add_overall() |> 
  gtsummary::add_p()
