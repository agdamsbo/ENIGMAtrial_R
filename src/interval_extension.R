interval_extension<-function(x,coln=1){
  # Function to extend written intervals in cells to "long" format by repeating associated variables.
  # x denotes the dataframe or vector to extend. coln denotes the desired column to extend the dataframe from. Default is 1. Only works with intervals seperated by "-".
  # Use case: extension of index tables, where several raw scores equals to the same indexscore.
  
  if (is.data.frame(x)&length(x)==1){
    stop("Check that input is correctly formatted as vector or that data frame has at least two columns")}
  
  if (!is.data.frame(x)&!is.vector(x)){stop("Check input format. Should be vector or data.frame")}
  
  if (is.data.frame(x)){
    dta<-cbind(x[coln],x[-coln])
    
    df<-data.frame(rbind(1:ncol(dta)))[0,]
    cnms<-colnames(dta)
    colnames(df)<-cnms
    
    for (i in 1:nrow(dta)){
      n<-as.numeric(unlist(strsplit(dta[i,1], "[-]")))
      suppressWarnings(dt<-data.frame(n[1]:n[2],dta[i,2:ncol(dta)]))
      # Unsure why this function results in a warning. Deal with it! B-)
      colnames(dt)<-cnms
      df<-rbind(df,dt)
    }
    return(df)
  }
  
  if (is.vector(x)){
    o<-c()
    for (i in 1:nrow(dta)){
      n<-as.numeric(unlist(strsplit(x[i], "[-]")))
      o<-c(o,n[1]:n[2])
    }
    return(o)
  }
}

## Example:
# test<-data.frame(int=c("1-3","4-9","10-15"),score=1:3,diff=4:6)
# interval_extention(test)
# interval_extention(test[,1])
