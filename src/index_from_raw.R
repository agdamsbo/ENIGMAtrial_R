index_from_raw<-function(dta,table_list=index_tables,version,age,raw_columns){
  library(dplyr)
  
  # dta<-d
  # table_list=index_tables
  # version=d$urbans_version
  # age=d$age
  # raw_columns=names(d[,4:8])
  
  version<-case_when(version == "1" ~ "a",
                     version == "2" ~ "b")
  
  ## Categorizing age to age interval of index lists
  ndx_nms<-names(table_list)[1:length(table_list)-1]
  
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
  cinms<-names(table_list[[1]])
  
  # Creating relevant colnames for index, CI and percentile
  abc<-paste0("rbans_",c(letters[1:length(cinms)],"ttl"))
  col_names_index<-paste0(abc,"_index",c(paste0("_",cinms),""))
  col_names_X95pct<-paste0(abc,"_X95pct")
  col_names_percentile<-paste0(abc,"_percentile")
  
  # Creating DF to populate with extracted data from table look-up
  col_names_all<-c("id",col_names_index,col_names_X95pct,col_names_percentile)
  df<-data.frame(matrix(1:length(col_names_all),ncol=length(col_names_all),nrow = nrow(dta),byrow = T))
  df[,1]<-dta$record_id
  colnames(df)<-col_names_all
  
  dt<-dta
  
  ## Create one function for when data provided is a list and when it is a data.frame. Currently works with data.frame
  
  for (i in 1:nrow(dta)){
    # i=1
    
    ## Selecting tables based on index age classification (all ages included from 18 and above, also above 89)
    lst<-table_list[[index_age[i]]]
    
    ## Selecting correct test version
    v<-version[i]
    
    # Converting each raw score to index score
    ndx<-c()
    X95<-c()
    per<-c()
    for (s in 1:length(lst)){
      # s=1
      # Index score
      
      flt<-filter(lst[[s]],total_rawscore==dt[i,raw_columns[s]]&version==v)
      
      ndx<-c(ndx,flt$indexscore)
      # 95 % CI
      X95<-c(X95,flt$X95_pct)
      # Percentile
      per<-c(per,flt$percentile)
    }
    
    ## Total index score from index sum
    ttl_scale<-index_tables[[length(index_tables)]][[1]]
    ndx_sum<-sum(ndx)
    flt_ttl<-filter(ttl_scale,total_index_scores==ndx_sum)
    ndx<-c(ndx,flt_ttl$indexscore)
    X95<-c(X95,flt_ttl$X95_pct)
    per<-c(per,flt_ttl$percentile)
    
    df[i,2:ncol(df)]<-c(ndx,X95,per)
  }
  
  # Percentiles and CIs are missing.
  
  return(df)
}