## =============================================================================
# RBANS mean score stratification
## =============================================================================

## =============================================================================
## Function
## =============================================================================

library(dplyr)

## Nnew read_redcap_data function introduced, that splits all forms into separate data.frames in list.
## Includes some clean-up.
## 

# source("src/read_redcap_tables.R")

## =============================================================================
## Data export
## =============================================================================

ls <- stRoke::read_redcap_tables(uri   = "https://redcap.au.dk/api/",
                      token= names(suppressWarnings(read.csv("/Users/au301842/enigma_redcap_token.csv",colClasses = "character"))),
                      fields = c("class_toast","record_id"),
                      forms= "rbans",
                      events= c("3_months_arm_1",
                                "12_months_arm_1",
                                "end_of_study_arm_1"))

df <- ls$rbans |> select(c("record_id",
                     "redcap_event_name",
                     ends_with("_is"))) |> 
  mutate(redcap_event_name=factor(redcap_event_name,
                                  levels = c("3_months_arm_1",
                                             "12_months_arm_1"),
                                  labels = c("3 måneder","12 måneder"))) |> 
  left_join(ls$klassifikation_af_primre_stroke |> select(record_id,class_toast)) |> 
  na.omit()

## =============================================================================
## Plots
## =============================================================================

table(df$redcap_event_name,df$class_toast)

# This should just be one pipe with facet.by=event

source("src/plot_index.R")

df |> select(-c(record_id)) |> group_by(class_toast,redcap_event_name) %>% 
  summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE))) %>% 
  mutate(class_toast=factor(class_toast,
                                levels = c("1","2","3","5"),
                                labels = c("Storkar","Småkar","Kardio", "Ukendt"))) %>%
  plot_index(id="class_toast",scores = colnames(.)[-1],facet.by = "redcap_event_name")+
  labs(title="Stratified mean RBANS scores",
       colour="TOAST")+
  geom_hline(yintercept = 70, linetype = 323, alpha = .5)+
  geom_hline(yintercept = 85, linetype = 323, alpha = .5)+
  geom_hline(yintercept = 100, alpha = .5)

  
## =============================================================================
## Notes
## =============================================================================

# Der skal tages højde for infarkt volumen, evt NIHSS
# 
# 
# 
