index_from_raw<-function(ds,indx,version,age,raw_columns,mani=FALSE){
  
  # Troubleshooting
  # ds = select(dta,c("record_id",ends_with("_rs")))
  # indx=read.csv("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/data/index.csv")
  # version = dta$urbans_version
  # age=dta$rbans_age
  # raw_columns=names(select(dta,ends_with("_rs")))
  
  
  library(dplyr)
  
  version<-case_when(version == "1" ~ "a",
                     version == "2" ~ "b")
  
  ## Categorizing age to age interval of index lists
  ndx_nms<-unique(unlist(sapply(strsplit(unique(indx$grp),"[_]"),"[[",2)))[1:6]
  
  ## This is the only non-generalised part. Please be inspired and solve it your own way! :)
  ## Intervals are 20-39, 40-49, 50-59, 60-69, 70-79, 80-89.
  ## Tried to use dplyr::case_when, didn't work
  ## Make universal by drawing interval names (needs to be changed to smth like "index_70.79" to use substr) and the use "for loop".
  index_age<-ifelse(age>=18&age<=39,ndx_nms[1],
                    ifelse(age>=40&age<=49,ndx_nms[2],
                           ifelse(age>=50&age<=59,ndx_nms[3],
                                  ifelse(age>=60&age<=69,ndx_nms[4],
                                         ifelse(age>=70&age<=79,ndx_nms[5],
                                                ifelse(age>=80,ndx_nms[6],NA))))))
  
  # Names of the different domains
  cinms<-unlist(sapply(strsplit(unique(indx$grp)[1:5],"[_]"),"[[",3))
    ## c("immediate","visuospatial","verbal","attention","delayed")
  
  # Creating relevant colnames for index, CI and percentile
  abc<-paste0("test_",c(letters[1:length(cinms)],"i"))
  col_names_index<-paste0(abc,"_is",c(paste0("_",cinms),"_total"))
  col_names_95pct<-paste0(abc,"_ci")
  col_names_percentile<-paste0(abc,"_per")
  
  # Creating DF to populate with extracted data from table look-up
  col_names_all<-c("id",col_names_index,col_names_95pct,col_names_percentile)
  df<-data.frame(matrix(1:length(col_names_all),ncol=length(col_names_all),nrow = nrow(ds),byrow = T))
  df[,1]<-ds$record_id
  colnames(df)<-col_names_all
  
  dt<-ds
  
  ## Create one function for when data provided is a list and when it is a data.frame. Currently works with data.frame
  
  for (i in 1:nrow(ds)){
    # i=1
    
    ## Selecting tables based on index age classification (all ages included from 18 and above, also above 89)
    lst<-list()
    for (j in 1:5){
      lst[[length(lst)+1]]<-indx %>% filter(grepl(cinms[j],grp)) %>% filter(grepl(index_age[i],grp))
    }
    
    names(lst)<-cinms
    
    ## Selecting correct test version
    v<-version[i]
    
    # Converting each raw score to index score
    ndx<-c()
    X95<-c()
    per<-c()
    
    ## Populating variables
    for (s in 1:length(lst)){
      # Index score
      # s=1
      flt<-lst[[s]]%>%filter(raw==dt[i,raw_columns[s]])%>%filter(ver==v)
      
      ndx<-c(ndx,flt$index)
      # 95 % CI
      X95<-c(X95,flt$pct95)
      # Percentile
      per<-c(per,flt$perc)
    }
    
    ## Total index score from index sum
    ttl_scale<-indx %>% filter(grepl("total_",grp))
    
    ndx_sum<-sum(ndx)
    flt_ttl<-filter(ttl_scale,raw==ndx_sum)
    ndx<-c(ndx,flt_ttl$index)
    X95<-c(X95,flt_ttl$pct95)
    per<-c(per,flt_ttl$perc)
    
    df[i,2:ncol(df)]<-c(ndx,X95,per)
  }
  
  if (mani==TRUE){
    sel1<-colnames(select(df,ends_with("_per")))
    for (i in sel1){
      df[,i]<-if_else(df[,i]=="> 99.9","99.95",
                      if_else(df[,i] =="< 0.1", "0.05",
                              df[,i]))
      ## Using the dplyr::if_else for a more stringent vectorisation
    }

  }
  
  return(df)
}
