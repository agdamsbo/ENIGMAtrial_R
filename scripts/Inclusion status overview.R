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


read_redcap_tables(uri = "https://redcap.au.dk/api/",
                         token = keyring::key_get("enigma_api_key"),
                         fields = c("record_id", "incl_by" , "incl_date", "eos1","eos2","eos3"),
                         forms = c("klassifikation_af_primre_stroke", 
                                   "baseline_stroke",
                                   "registrering",
                                   "baseline_nihss")
) |> lapply(function(i){
  i[colnames(i)!="redcap_event_name"]
}) |> Reduce(f = full_join, x = _) |> 
  assign("d",value = _)

# Visuals
source("src/status_plot.R")

p1+p2

# Sammentællinger af inlusionsansvarlige, skanninger mm


d |>
  select(age,
         kon,
         hypertension,
         diabetes,
         resist_incl,
         nihss_baseline_sum,
         class_toast,
         eos2,incl_by) |>
  # mutate(eos2 = forcats::fct_explicit_na(eos2)) |> 
  tbl_summary(by = "kon", missing = "ifany") |>
  add_p() |> 
  add_overall()

  
  
