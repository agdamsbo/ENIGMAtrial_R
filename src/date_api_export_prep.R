
d_mod <- d |> 
  # Defining variable for next visit
  mutate(eos_next_book=as.POSIXct(ifelse(is.na(visit_book12),incl_book3,visit_book12))) |> 
  # Filter to only include patients booking after EOS if early out
  # filter(eos_next_book>=eos1) |> 
  # Filter to only include patients not completed
  filter(is.na(eos1)) |> 
  # Exclude EOS vars
  select(-starts_with("eos"))

splitter <- gsub("^\\d.*|[A-Za-z_]", "", colnames(d_mod)) |> stRoke::add_padding(pad = "0") %>% paste0("A",.)|> factor()

d_list <- d_mod |> split.default(f = splitter)

# select(d_list[[2]],contains("_book"))

reg <- c(0,3,12)*30
# Interval range to ensure booked times are within protocol definitions
reg_range <- data.frame(time1=reg-15,time2=reg+15)

df_all <- lapply(2:3,function(i){
  tibble(
    id=d_list[[1]][,1],
    start=d_list[[i]][,1],
    room=ifelse(is.na(d_list[[i]][,2]),d_list[[i]][,3],d_list[[i]][,2]),
    time2visit_check = difftime(
      start |> as.character() |> substr(1, 10) |> as.Date(),
      as.Date(d_list[[1]][, 2], format = "%Y-%m-%d %H:%M:%S"),
      units = "days"
    ) |> round(),
    protocol_check = time2visit_check %in% seq(reg_range[i, 1], reg_range[i, 2]) &
      !is.na(time2visit_check),
    name=paste(gsub("[A0]", "", names(d_list)[i]),"mdr")
  )
}) |> bind_rows() |> 
  # Filter to only include bookings after current date (include previous five days)
  filter((start>ymd_hms(lubridate::now())-90*86400 | is.na(start)&!protocol_check)) |>
  # Inly include the first coming visit
  filter(!duplicated(id))

# Clean-up
source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/remove_all_but.R")
remove_all_but(df_all,d)


# date_api_export_prep<-function(dta,include_all=FALSE,cut_date=-5,num_c=2,ev_names=c("3mdr","12mdr"),date_col="_book",room_col="_room",other_col="_other"){
#   ## Troubleshooting ##
#   ## 
#   # include_all=FALSE
#   # cut_date=-5
#   # num_c=2
#   # ev_names=c("3mdr","12mdr")
#   # date_col="_book"
#   # room_col="_room"
#   # other_col="_other"
#   ## END ##
#   
#   # Depends on file formatted as REDCap export files with date of export in filename
#   # cut_date defines the date to cut, if any. Negative values defines number of days before provided date from filename
#   library(tidyr)
#   library(dplyr)
#   library(lubridate)
# 
#   
#   if (num_c!=length(ev_names)){stop("Length of ev_names has to be the same as the value of num_c")}
#   
#   d <- dta
#   
#  
#   
#   d$incl_room3<-ifelse(d$incl_room3==1,"J109-139",ifelse(d$incl_room3==2,"J109-141",ifelse(d$incl_room3==3,d$incl_other3,NA)))
#   d$visit_room12<-ifelse(d$visit_room12==1,"J109-139",ifelse(d$visit_room12==2,"J109-141",ifelse(d$visit_room12==3,d$visit_other12,NA)))
#   
#   cs<-c(date_col,room_col)
#   cd<-d
#   for (i in 1:length(cs)){
#     dt<-select(d,contains(cs[i]))
#     ds<-ifelse(dt[[1]]==""|is.na(dt[[1]]),dt[[2]],dt[[1]])
#     cd<-data.frame(cd,ds)
#     }
#   
#   dl<-cd[c(1,2,(length(d)+1):length(cd))]
#   colnames(dl)<-c("id","name","start","room")
#   
#   dl<-dl[dl$name=="inclusion_arm_1"|dl$name=="3_months_arm_1",]
# 
#   ## Binary solution - non-universal, fast solution
#   nms<-rev(levels(factor(dl$name)))
#   for (i in 1:nrow(dl)){
#     dl$name[i]<-ifelse(dl$name[i]==nms[1],ev_names[1],ev_names[2])  
#   }
#   
#   if (include_all==FALSE){
#     file.date<-ymd_hms(lubridate::now())+cut_date*86400
#     #Sets cutoff date to include events only from this date and forward. Date is acquired from the filename.
#     dl<-dl[ymd_hm(dl$start)>file.date&!is.na(dl$start),]
#   }
#   if (include_all==TRUE){
#     dl<-dl[!is.na(dl$start),]
#   }
#   dl
#   # Wow, this is crude! But it works! Hurra!
# }
