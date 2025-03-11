if (!requireNamespace("REDCapCAST")) install.packages("REDCapCAST")

library(REDCapCAST)
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
    # MoCA scores
    "i_score"
  ),
  # Relevant arms in a longitudinal project
  events = c("inclusion_arm_1", "3_months_arm_1"),
  raw_or_label = "both", 
  data_format = "wide"
) |> REDCapCAST::as_factor()
