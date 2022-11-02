## RBANS calculations upload

## =============================================================================
## Step 1: Pre-reading
## =============================================================================

records_mod <- redcap_read_oneshot(
  redcap_uri   = uri,
  token        = token,
  fields       = c("record_id","eos_data_mod","rbans_perf") ## Only selecting relevant variables
)$data %>%
  filter(redcap_event_name %in% c("12_months_arm_1","end_of_study_arm_1"))

# For trouble shooting
# records_mod$eos_data_mod<-NA

if (all_ids_12==FALSE){
  # IDs with performed RBANS, and not yet modified
  ids<-setdiff(records_mod$record_id[!is.na(records_mod$rbans_perf==1)], #IDs with 12 months RBANS performed
               na.omit(records_mod$record_id[records_mod$eos_data_mod=="yes"]) #IDs with data modified already
  ) 
}

if (all_ids_12==TRUE){
## Set all IDs for reupload
ids<-records_mod$record_id[!is.na(records_mod$rbans_perf==1)]
}

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
  fields       = "record_id"
)$data
  

## Handling 12 months

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/redcap_rbans_lookup.R")

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

