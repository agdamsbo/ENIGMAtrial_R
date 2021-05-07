date_file_prep<-function(folder,include_all=FALSE,cut_date=-5,num_c=2,ev_names=c("3mdr","12mdr"),date_col="_book",room_col="_room",other_col="_other"){
  # Depends on file formatted as REDCap export files with date of export in filename
  # cut_date defines the date to cut, if any. Negative values defines number of days before provided date from filename
  library(tidyr)
  library(dplyr)
  library(lubridate)
  if (num_c!=length(ev_names)){stop("Length of ev_names has to be the same as the value of num_c")}
  
  source("watch_folder_csv.R")
  
  #folder<-"/Users/andreas/REDCap_conversion/calendar"
  
  wfc<-watch_folder_csv(folder = folder)
  # The watch_folder_csv.R outputs a list with 1) a dataframe and 2) the original full filename
  
  d<-wfc[[1]]

  d<-data.frame(id=d$record_id,room=select(d,contains(room_col)),select(d,contains(date_col)),select(d,contains(other_col)))
  
  dl <- tidyr::pivot_longer(data=d, cols=contains(date_col))
  
  dl$incl_room3<-ifelse(dl$incl_room3==1,"J109-139",ifelse(dl$incl_room3==2,"J109-141",ifelse(dl$incl_room3==3,dl$incl_other3,NA)))
  dl<-dl[,-3]
  
  nms<-levels(factor(dl$name))
  for (i in 1:nrow(dl)){
    for (j in 1:length(nms))
      dl$name[i]<-ifelse(dl$name[i]==nms[j],ev_names[j],dl$name[i])  
  }
  
  #dl$value<-ymd_hm(dl$value)
  
  if (include_all==FALSE){
    file.date<-ymd(unlist(strsplit(tail(unlist(strsplit(wfc[[2]], "[/]")),n=1),"[_]"))[3])+cut_date
    #Sets cutoff date to include events only from this date and forward. Date is acquired from the filename.
    dl<-dl[ymd_hm(dl$value)>file.date&!is.na(dl$value),]
  }
  if (include_all==TRUE){
    dl<-dl[!is.na(dl$value),]
  }
  colnames(dl)<-c("id","room","name","start")
  return(dl)
  # Wow, this is crude! But it works!
}
