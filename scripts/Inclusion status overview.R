# Inclusion status
# 
# inc<-c("incl_date", "incl_by")
# eos<-c("eos1","eos2","eos3")
# 
# field_list<-list(inc,eos)
# names(field_list)<-c("inclusion_arm_1","end_of_study_arm_1")
# 
# source("src/redcap_api_export.R")
# d<-redcap_api_export(fld_lst=field_list,reduced=TRUE)

source("/Users/au301842/stRoke/drafts/read_redcap_tables.R")
library(ggplot2); library(dplyr); library(gtsummary); library(patchwork)

inst <- REDCapR::redcap_instruments(redcap_uri = "https://redcap.au.dk/api/",
                            token = keyring::key_get("enigma_api_key"))$data

read_redcap_tables(uri = "https://redcap.au.dk/api/",
                         token = keyring::key_get("enigma_api_key"),
                         fields = c("record_id", "incl_by" , "incl_date", "eos1","eos2","eos3"),
                         forms = c("klassifikation_af_primre_stroke", 
                                   "baseline_stroke",
                                   "registrering",
                                   "baseline_nihss",
                                   "hjde_vgt_og_blodtryk",
                                   "rygeanamnese")
) |> #lapply(function(i){
#   i[colnames(i)!="redcap_event_name"]
# }) |> Reduce(f = full_join, x = _) |> 
  assign("d",value = _)

d_rep <- d[do.call(rbind,lapply(d, function(i){
  any(duplicated(i[["record_id"]]))
}))]

lapply(seq_len(length(d_rep)), function(i) {
  pivot_wider(d_rep[[i]], 
              id_cols = "record_id", 
              names_from = "redcap_event_name",
              values_from = everything())
})

vals_out <- colnames(d_rep$hjde_vgt_og_blodtryk)%in%c("record_id","redcap_event_name")
vals <- colnames(d_rep$hjde_vgt_og_blodtryk)[!vals_out]

d_w <- pivot_wider(d_rep$hjde_vgt_og_blodtryk,
            names_from = redcap_event_name,
            values_from = all_of(vals))



# Visuals
source("src/status_plot.R")

p1+p2

# Sammentællinger af inlusionsansvarlige, skanninger mm


d |>
  select(age,
         kon,civil,
         hypertension,
         diabetes,
         resist_incl,
         nihss_baseline_sum,
         class_toast,
         eos2,incl_by) |>
  # mutate(eos2 = forcats::fct_explicit_na(eos2)) |> 
  mutate(hypertension = ifelse(hypertension == "Nej",FALSE,TRUE),
         diabetes = ifelse(diabetes == "Nej",FALSE,TRUE),
         ) |> 
  tbl_summary(by = "kon", missing = "ifany",) |>
  add_p() |> 
  add_overall()

  
  
