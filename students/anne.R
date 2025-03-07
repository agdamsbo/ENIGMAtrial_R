## Go to the project codebook to look for field and event names
## https://redcap.au.dk/redcap_v14.5.36/Design/data_dictionary_codebook.php?pid=5397

################################################################################
###########
###########
###########   Wide data for baseline plotting
###########
###########
################################################################################

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
    # Cognitive scores
    "iq_score",
    "i_score",
    # PA
    "pase_completed",
    "pase_score"
  ),
  # Relevant arms in a longitudinal project
  events = c("inclusion_arm_1", "12_months_arm_1"),
  raw_or_label = "both", data_format = "wide"
) |> REDCapCAST::as_factor()

## Renaming
names(df) <- gsub("____inclusion_arm_1", "_0",gsub("____12_months_arm_1", "_1", names(df)))

## Ensuring only true PASE values are kept
df <- df |>
  dplyr::mutate(pase_score_0 = dplyr::if_else(is.na(pase_completed_0), NA, pase_score_0),
                pase_score_1 = dplyr::if_else(is.na(pase_completed_1), NA, pase_score_1)) |> 
  dplyr::select(-tidyselect::starts_with("pase_completed")) # pase_completed variables are dropped

# Processing metadata to reflect focused dataset

if (!requireNamespace("gtsummary")) install.packages("gtsummary")
## Example table to show how labels are kept and used in tables
df |>
  REDCapCAST::as_factor() |>
  REDCapCAST::fct_drop() |>
  gtsummary::tbl_summary(
    by = kon
  ) |>
  gtsummary::add_overall() |>
  gtsummary::add_p()

################################################################################
###########
###########
###########   On pivoting wide to long
###########
###########
################################################################################

## Give the unique suffix names to use for identifying repeated measures
suffixes <- c("_0", "_1")

## Relevant columns are determined based on suffixes
cols <- names(df)[grepl(paste0("*(", paste(suffixes, collapse = "|"), ")$"), names(df))]

## New colnames are created by removing suffixes
new_names <- unique(gsub(paste(suffixes, collapse = "|"), "", cols))

long_missings <- split(df, seq_len(nrow(df))) |> # Splits dataset by row
  # Starts data modifications for each subject
  lapply(\(.x){
    ## Pivots data with repeated measures as determined by the defined suffixes
    long_ls <- split.default(
      # Subset only repeated data
      .x[cols],
      # ... and split by meassure
      gsub(paste(new_names, collapse = "|"), "", cols)
    ) |>
      # Sort data by order of given suffixes to ensure chronology
      sort_by(suffixes) |>
      # New colnames are applied
      lapply(\(.y){
        setNames(
          .y,
          gsub(paste(suffixes, collapse = "|"), "", names(.y))
        )
      })

    # Subsets non-pivotted data (this is assumed to belong to same )
    single <- .x[-match(cols, names(.x))]
    
    # Extends with empty rows to get same dimensions as long data
    single[(nrow(single)+1):length(long_ls),] <- NA
    
    # Assumes first column is ID
    single <- single |> tidyr::fill(names(single)[1])

    # Everything is merged together
    dplyr::bind_cols(
      single,
      # Instance names are defined as suffixes without leading non-characters
      data.frame(instance = gsub(
        "^[^[:alnum:]]+", "",
        names(long_ls)
      )),
      dplyr::bind_rows(long_ls)
    )
  }) |> dplyr::bind_rows()

# Optional filling of missing values by last observation carried forward
# Needed for mmrm analyses
long_complete <- long_missings |> 
  dplyr::group_by(record_id) |> 
  tidyr::fill()

# Creating a time-wise summary table of repeated meassures
long_complete[c("instance",new_names)] |> 
  gtsummary::tbl_summary(by=instance)

################################################################################
###########
###########
###########   Sankey plotting example
###########
###########
################################################################################

if (!requireNamespace("freesearcheR")) pak::pak("agdamsbo/freesearcheR")

ds <- data.frame(g = sample(LETTERS[1:2], 100, TRUE), first = REDCapCAST::as_factor(sample(letters[1:4], 100, TRUE)), last = REDCapCAST::as_factor(sample(letters[1:4], 100, TRUE)))
ds |> freesearcheR::plot_sankey_single("first", "last", numbers = "percentage")

################################################################################
###########
###########
###########   Long data and MMRM analysis
###########
###########
################################################################################

# Get the latest REDCapCAST version
# pak::pak("agdamsbo/REDCapCAST")

df_long <- REDCapCAST::easy_redcap(
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
    "pase_completed",
    "pase_score"
  ),
  # Relevant arms in a longitudinal project
  events = c("inclusion_arm_1", "12_months_arm_1"),
  raw_or_label = "both", data_format = "long"
)

df_mmrm <- df_long |>
  as_factor() |> # Applying REDCap metadata
  fct_drop() |> # Remove empty factor levels
  dplyr::mutate( # Format ID and instance as factors
    record_id = REDCapCAST::as_factor(record_id),
    redcap_event_name = REDCapCAST::as_factor(redcap_event_name),
    hypertension = dplyr::if_else(startsWith(as.character(hypertension), "Ja,"), TRUE, FALSE),
    diabetes = dplyr::if_else(startsWith(as.character(diabetes), "Ja,"), TRUE, FALSE)
  ) |>
  dplyr::mutate(pase_score = dplyr::if_else(is.na(pase_completed), NA, pase_score)) |> # Corrects PASE scores calculated as 0, while should be missing
  dplyr::select(-pase_completed) |> # Excluding pase_completed variable
  dplyr::arrange(record_id, redcap_event_name) |> # Arranging for better overview
  dplyr::group_by(record_id) |> # Grouping for filling
  tidyr::fill(c( # Fill in missings as Last observation carried forward
    "age", "kon",
    # Cronical diseases
    "diabetes",
    "hypertension",
    # NIHSS score
    "nihss_baseline_sum",
    # Cognitive scores
    "iq_score",
    "i_score"
  )) |>
  dplyr::ungroup() # Ungrouping

if (!requireNamespace("mmrm")) install.packages("mmrm")

## Creating an MMRM fit object using default settings
mmrm_model <- mmrm::mmrm(
  formula = pase_score ~ hypertension + diabetes + nihss_baseline_sum + iq_score + i_score + age + us(redcap_event_name | record_id),
  data = df_mmrm
)

summary(mmrm_model)
broom::glance(mmrm_model)

## Rendering a table
gtsummary::tbl_regression(mmrm_model) |> gtsummary::bold_p()
