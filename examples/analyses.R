targets::tar_read(data) |>
  # dplyr::select(
  #   age,
  #   kon,
  #   civil,
  #   hypertension,
  #   diabetes,
  #   # resist_incl,
  #   nihss_baseline_sum,
  #   treated_thrombolysis,
  #   treated_thrombectomy
  # ) |>
  dplyr::transmute(
    age = age,
    kon = kon,
    # civil = civil == "Bor alene",
    hypertension = hypertension != "Nej",
    diabetes = diabetes != "Nej",
    afli = afli != "Nej",
    previous_stroke = previous_stroke != "Nej",
    previous_tia = previous_tia != "Nej",
    # resist_incl = resist_incl == "Ja",
    nihss = nihss_baseline_sum,
    class_toast = factor(
      dplyr::case_match(class_toast,
        "Ukendt årsag" ~ "Unknown",
        "Småkarssygdom" ~ "Small vesel disease",
        "Storkarssygdom" ~ "Large vessel disease",
        "Kardioemboli" ~ "Cardioembolic",
        "Anden årsag" ~ "Other",
        .default = "Not classified"
      ),
      levels = c(
        "Small vesel disease",
        "Large vessel disease",
        "Cardioembolic",
        "Other",
        "Unknown",
        "Not classified"
      )
    ),
    thrombolysis = treated_thrombolysis == "Ja",
    thrombectomy = treated_thrombectomy == "Ja"
  ) |>
  gtsummary::tbl_summary(
    # by = "kon",
    missing = "no",
    label = list(
      age ~ "Alder",
      diabetes ~ "Diabetes",
      hypertension ~ "Hypertension",
      afli ~ "Known Afib",
      previous_stroke ~ "Previous stroke",
      previous_tia ~ "Previous TIA",
      nihss ~ "NIHSS at admission",
      kon ~ "Sex",
      class_toast ~ "TOAST classification",
      thrombolysis ~ "IVT",
      thrombectomy ~ "EVT"
    )
  ) |> gtsummary::as_gt() |> gt::gtsave(here::here("output/baseline_sigrid.docx"))

