date_file_prep<-function(folder,include_all=FALSE,cut_date=-5,num_c=2,ev_names=c("3mdr","12mdr"),date_col="_book",room_col="_room",other_col="_other"){
  # Depends on file formatted as REDCap export files with date of export in filename
  # cut_date defines the date to cut, if any. Negative values defines number of days before provided date from filename
  library(tidyr)
  library(dplyr)
  library(lubridate)
  if (num_c!=length(ev_names)){stop("Length of ev_names has to be the same as the value of num_c")}
  
  source("src/watch_folder_csv.R")
  
  ## Trouble shooting ##
  # folder="/Users/andreas/REDCap_conversion/calendar"
  # include_all=FALSE
  # cut_date=-5
  # num_c=2
  # ev_names=c("3mdr","12mdr")
  # date_col="_book"
  # room_col="_room"
  # other_col="_other"
  ## END ##
  
  wfc<-watch_folder_csv(folder = folder)
  # The watch_folder_csv.R outputs a list with 1) a dataframe and 2) the original full filename
  
  d<-wfc[[1]]
  # d<-select(d,!contains("redcap"))

  ## Loading example data ##
  # d$visit_room12[is.na(d$incl_room3)]<-2
  # d$visit_book12[is.na(d$incl_room3)]<-as.character(ymd_hm(last(d$incl_book3))+7200*as.numeric(d$record_id[is.na(d$incl_room3)]))
  ## END ##
  
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
  
  nms<-levels(factor(dl$name))
  for (i in 1:nrow(dl)){
    for (j in 1:length(nms))
      dl$name[i]<-ifelse(dl$name[i]==nms[j],rev(ev_names)[j],dl$name[i])  
  }
  
  if (include_all==FALSE){
    file.date<-ymd(unlist(strsplit(tail(unlist(strsplit(wfc[[2]], "[/]")),n=1),"[_]"))[3])+cut_date
    #Sets cutoff date to include events only from this date and forward. Date is acquired from the filename.
    dl<-dl[ymd_hm(dl$start)>file.date&!is.na(dl$start),]
  }
  if (include_all==TRUE){
    dl<-dl[!is.na(dl$start),]
  }
  return(dl)
  # Wow, this is crude! But it works!
}
