date_api_export_prep<-function(dta,include_all=FALSE,cut_date=-5,num_c=2,ev_names=c("3mdr","12mdr"),date_col="_book",room_col="_room",other_col="_other"){
  ## Troubleshooting ##
  include_all=FALSE
  cut_date=-5
  num_c=2
  ev_names=c("3mdr","12mdr")
  date_col="_book"
  room_col="_room"
  other_col="_other"
  ## END ##
  
  # Depends on file formatted as REDCap export files with date of export in filename
  # cut_date defines the date to cut, if any. Negative values defines number of days before provided date from filename
  library(tidyr)
  library(dplyr)
  library(lubridate)

  
  if (num_c!=length(ev_names)){stop("Length of ev_names has to be the same as the value of num_c")}
  
  d <- dta
  
  d$incl_room3<-ifelse(d$incl_room3==1,"J109-139",ifelse(d$incl_room3==2,"J109-141",ifelse(d$incl_room3==3,d$incl_other3,NA)))
  d$visit_room12<-ifelse(d$visit_room12==1,"J109-139",ifelse(d$visit_room12==2,"J109-141",ifelse(d$visit_room12==3,d$visit_other12,NA)))
  
  cs<-c(date_col,room_col)
  cd<-d
  for (i in 1:length(cs)){
    dt<-select(d,contains(cs[i]))
    ds<-ifelse(dt[[1]]==""|is.na(dt[[1]]),dt[[2]],dt[[1]])
    cd<-data.frame(cd,ds)
    }
  
  dl<-cd[c(1,2,(length(d)+1):length(cd))]
  colnames(dl)<-c("id","name","start","room")
  
  dl<-dl[dl$name=="inclusion_arm_1"|dl$name=="3_months_arm_1",]

  ## Binary solution - non-universal, fast solution
  nms<-rev(levels(factor(dl$name)))
  for (i in 1:nrow(dl)){
    dl$name[i]<-ifelse(dl$name[i]==nms[1],ev_names[1],ev_names[2])  
  }
  
  if (include_all==FALSE){
    file.date<-ymd_hms(lubridate::now())+cut_date*86400
    #Sets cutoff date to include events only from this date and forward. Date is acquired from the filename.
    dl<-dl[ymd_hm(dl$start)>file.date&!is.na(dl$start),]
  }
  if (include_all==TRUE){
    dl<-dl[!is.na(dl$start),]
  }
  return(dl)
  # Wow, this is crude! But it works! Hurra!
}
