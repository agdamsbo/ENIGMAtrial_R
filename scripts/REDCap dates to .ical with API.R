
# Workflow:
# 
# 
# 

## =============================================================================
## Getting data from REDCap
## =============================================================================

# REDCap data export/import script
token <- keyring::key_get("enigma_api_key"); source("src/date_api_export.R")
## Drops environment but data.frame

# Formatting
source("src/date_api_export_prep.R")
df <-
  date_api_export_prep(
    dta = d,
    include_all = FALSE,
    cut_date = -1,
    num_c = 2,
    date_col = "_book",
    room_col = "_room"
  )
## Includes only one appointment for each ID. Problem?

## Excluding patients with booking, but with EOS filled due to early end of study (ie date of EOS not blank)
df_all <- df[!(df$id %in% d$record_id[!is.na(d$eos1)]),]


## =============================================================================
## Export spreadsheet with assessors on assigned
## =============================================================================

output_folder <- "/Users/au301842/ENIGMAtrial_R/output/kontrol"

files_filter <- function(folder.path,filter.by,full.names=TRUE){
  # List files in folder
  files <- list.files(path=folder.path,full.names=full.names)
  
  # Gets names of all files ending on kotroller_f (filled)
  files[grepl(filter.by,files)] 
}

filled <- files_filter(output_folder,"kontroller_f")

# Loads the last (newest) filled spreadsheet to include new changes
old_filled_file <- readODS::read_ods(filled[length(filled)])

# End date is 85 days after render date not to forget recently included patients for 3 months follow-up.
end.date<-as.Date(Sys.Date())+120

# Format for nice printing
Sys.setlocale("LC_TIME", "da_DK.UTF-8")

df <- df_all |>
  arrange(start) |>
  filter(start < end.date) |>
  left_join(old_filled_file |> select(id, assessor)) %>%
  mutate(old = as.character(format(
    left_join(x = ., y = old_filled_file[c("id", "tid")])[, "tid"], 
    format = "%Y-%m-%d %H:%M"
  )),
  changes = if_else(start != old, "ÆNDRET", "samme")) |>
  rename(tid = start) |>
  select(-old)

# Joins the filled file with the original. Keeps original time stamps

file_path <- paste0(output_folder,"/",
                    format(as.POSIXct(Sys.Date()), 
                           format = "%Y%m%d"),
                    "_kontroller.ods")

df |> transmute(tid, id, kontrol=name, 
                assessor=ifelse(!is.na(assessor),assessor,"")) |> 
  readODS::write_ods(path = file_path)

system2("open",output_folder)
system2("open",file_path)

## =============================================================================
## Including assessor
## =============================================================================

# stop("PART 2: fill file and continue manually!")

filled <- files_filter(output_folder,"kontroller_f")

# Loads the last (newest) filled spreadsheet to include new changes
filled_file <- readODS::read_ods(filled[length(filled)])

# Joins the filled file with the original. Keeps original time stamps
f <- inner_join(df[c("id","name","tid")],filled_file[,colnames(filled_file)!="tid"])

# Mutates and joins for better labelling
df_cal <- f |> transmute(id=id,
                    name2=ifelse(!is.na(assessor),
                                 paste0(kontrol," [",toupper(assessor),"]"),
                                 NA)) |> 
  right_join(df_all) |> 
  mutate(label=ifelse(!is.na(name2),name2,name))


## =============================================================================
## Creating calendar and comitting
## =============================================================================

# Conversion to calendar files (.ics)
library(calendar)
source("src/convert_ical.R")
convert_ical(df_cal, 
             start="start",
             id="id",
             name="label",
             room="room")[[2]] |> 
  ic_write(file="enigma_control.ics")

# Commit and push GIT
source("src/enigma_git_push.R")
enigma_git_push(paste("calendar update",Sys.Date()))

# Clean environment
rm(list=ls(pos=1))

