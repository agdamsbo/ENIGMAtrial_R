install.packages("REDCapCAST")

REDCapCAST::easy_redcap(
  project.name = "ENIGMA",
  uri = "https://redcap.au.dk/api/",
  fields = c(
    # record_id benyttes alene som index
    "record_id",
    # Alder og køn
    "age", "kon",
    # Knnown diabetes
    "diabetes",
    "hba1c",
    # Spot glucose
    "glut",
    "nihss_baseline_sum",
    # De følgende seks variabler er RBANS domæne scores samt samlet total index score
    "rbans_a_is", "rbans_b_is", "rbans_c_is", "rbans_d_is", "rbans_e_is", "rbans_i_is",
    # IQCODE score
    "iq_score"
  ),
  events = c("inclusion_arm_1", "3_months_arm_1")
)
