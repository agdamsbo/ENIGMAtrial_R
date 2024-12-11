## RBANS calculations upload

## =============================================================================
## Step 1: Pre-reading
## =============================================================================

records_mod <- redcap_read_oneshot(
  redcap_uri   = uri,
  token        = token,
  fields       = c("record_id","eos_data_mod","rbans_perf","rbans_a_rs","rbans_b_rs","rbans_c_rs","rbans_d_rs","rbans_e_rs") ## Only selecting relevant variables
)$data %>%
  filter(redcap_event_name %in% c("12_months_arm_1","end_of_study_arm_1"))

# For trouble shooting
# records_mod$eos_data_mod<-NA

## 230929: These scripts are not written to account for missing entries in raw RBANS scores
## This modification is added to handle missing entries a little more gracefully
## Determining if missing any raw scores
missing.raws <- apply(is.na(select(records_mod,ends_with("_rs"))),1,any)

## Complete entries
complete.12.entries <- records_mod$record_id[!missing.raws]

# print(paste("Missing raw RBANS scores for subject",paste(records_mod$record_id[missing.raws],collapse = ", ")))
if (all_ids_12){
  ## Set all IDs for reupload
  ids<-complete.12.entries
} else {
  # IDs with performed RBANS, and not yet modified
  ids<-setdiff(complete.12.entries, #IDs with 12 months RBANS performed
               na.omit(records_mod$record_id[records_mod$eos_data_mod=="yes"]) #IDs with data modified already
  ) 
}

## Old approach just checks if the flag "performed" was checked
# if (all_ids_12==FALSE){
#   # IDs with performed RBANS, and not yet modified
#   ids<-setdiff(records_mod$record_id[!is.na(records_mod$rbans_perf==1)], #IDs with 12 months RBANS performed
#                na.omit(records_mod$record_id[records_mod$eos_data_mod=="yes"]) #IDs with data modified already
#   ) 
# }
# 
# if (all_ids_12==TRUE){
# ## Set all IDs for reupload
# ids<-records_mod$record_id[!is.na(records_mod$rbans_perf==1)]
# }

## =============================================================================
## Step 2: Doing table look-ups for RBANS incl upload
## =============================================================================

# Everything is wrapped within an "if" loop to only run if records are available 

if (length(ids)>0){
### Data export
dta <- redcap_read(
  redcap_uri   = uri,
  token        = token,
  events       = "12_months_arm_1",
  raw_or_label = "raw",
  records      = ids,
  forms        = c("rbans","rbans_konklusion","mrs"),
  fields       = "record_id", 
  filter_logic = "[rbans_perf]='1' and [rbans_complete]='2'"
)$data

dta <- dta |> dplyr::mutate(rbans_age = floor(stRoke::age_calc(dob=readr::parse_date(rbans_dob,format="%d-%m-%Y"),enddate=rbans_date)))  

## Handling 12 months

source(here::here("src/redcap_rbans_lookup.R"))
# source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_rbans_lookup.R")

## Last minute flag to indicate modification performed
df<-df%>%full_join(.,data.frame(record_id=.$record_id,
                            redcap_event_name="end_of_study_arm_1",
                            eos_data_mod="yes"),
               by=c("record_id","redcap_event_name"))

## Write

stts<-redcap_write(ds=df,
                   redcap_uri   = uri,
                   token        = token)

## =============================================================================
## Step 3: Conclusions data
## =============================================================================

## Common variables for 3 + 12 months
cols<-colnames(select(df,c("record_id",ends_with(c("_is","_per","name")))))

rb12<-df%>%
  select(all_of(cols))%>%
  left_join(.,dta%>%
              select(c("record_id","mrs_score")),by="record_id")%>%
  filter(redcap_event_name=="12_months_arm_1")

rb3<-redcap_read(
  redcap_uri   = uri,
  token        = token,
  events       = "3_months_arm_1",
  raw_or_label = "raw",
  records      = ids,
  forms        = c("rbans","mrs"),
  fields       = c("record_id")
)$data%>%
  select(all_of(cols),"mrs_score")

## Prestroke mRS
rb0<-redcap_read(
  redcap_uri   = uri,
  token        = token,
  events       = "inclusion_arm_1",
  raw_or_label = "raw",
  records      = ids,
  forms        = c("mrs","iqcode"),
  fields       = c("record_id")
)$data%>%
  select("record_id","mrs_score","iq_score")

## =============================================================================
## Step 4: Conclusions text
## =============================================================================

doms<-c("immediate","visuospatial","verbal","attention","delayed","total")
txts<-c()

# Texts for each ID
for (i in seq_along(ids)) {
  rb0_s<-rb0[i,]
  rb3_s<-rb3[i,]
  rb12_s<-rb12[i,]
  
txt_mrs<-paste(c("Prestroke","3 months","End of Study"),"mRS:",
               c(rb0_s$mrs_score,rb3_s$mrs_score,rb12_s$mrs_score),
               collapse = ", ")

txt_iqcode<-paste("At inclusion, IQCODE score was:",
                  rb0_s$iq_score,
                  "(48 is normal, higher indicates decline)")

txt_md3<-paste0("3 months RBANS index scores (percentile) for the domains were ", 
               paste(doms, 
                     paste0(select(rb3_s,ends_with("_is"))," (",
                            select(rb3_s,ends_with("_per")),")"),
                     sep = ": ",collapse=", ")
               )

txt_md12<-paste0("12 months RBANS index scores (percentile) for the domains were ", 
                 paste(doms, 
                       paste0(select(rb12_s,ends_with("_is"))," (",
                              select(rb12_s,ends_with("_per")),")"),
                       sep = ": ",collapse=", ")
                )

if (rb12_s$mrs_score>=2 & rb12_s$rbans_i_is<=70) {
  txt_demens<-"OBS: Pt opfylder muligvis kriterierne for demens"
} else {
  txt_demens<-"Pt opfylder ikke kriterierne for demens"}

txt_note<-"NOTE: Index score at 70-85 is 'forringet', and <70 is 'reduceret'"

txts[i]<-paste0(paste(txt_mrs,txt_iqcode,txt_md3,txt_md12,txt_demens,txt_note,
        sep=".\n"),
        "."
        )
}

# Creating upload data frame
dc<-data.frame(record_id=ids,
               rbans_conc_text=txts,
               redcap_event_name="12_months_arm_1")

## =============================================================================
## Step 5: Conclusions upload
## =============================================================================

stts<-redcap_write(ds=dc,
                   redcap_uri   = uri,
                   token        = token)
} 

