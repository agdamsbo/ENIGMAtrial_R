if (!requireNamespace("REDCapCAST")) install.packages("REDCapCAST")

## Go to the project codebook to look for field and event names
## https://redcap.au.dk/redcap_v14.5.36/Design/data_dictionary_codebook.php?pid=5397
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
  # Relevant arms in a longitudinal project
  events = c("inclusion_arm_1", "3_months_arm_1", "12_months_arm_1"),
  widen.data = TRUE
)

if (!requireNamespace("gtsummary")) install.packages("gtsummary")
## Example table to show how labels are kept and used in tables
df |>
  gtsummary::tbl_summary(
    by = kon
  ) |> 
  gtsummary::add_overall() |> 
  gtsummary::add_p()
