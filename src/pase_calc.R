pase_calc<-function(dat,ends_26,ends_2a6b,ends_79b,ends_1010a,sum_dec=2){
  require(dplyr)
  # Follows the example given in the original PASE handbook appendix C.
  # The required column variables can be given as the full name, or the last unique part of column names.
  
reco.multi.26<-function(dat,ends_w){
  require(dplyr)
  df<-select(dat,ends_with(ends_w))
  
  reco<-function(var){
    # Simple dedicated recode function
    c<-c()
    for(i in 1:length(var)){
      c<-c(c,switch(var[i],"0"=0,"1"=1.5,"2"=3.5,"3"=6,0))}
    return(c)
  }
  
  d<-data.frame(df[[1]])
  for(t in 1:ncol(df)){
    d<-data.frame(d,reco(as.character(df[[t]])))
  }
  d<-d[,-1]
  colnames(d)<-paste0("Q",ends_w)
  return(d)
}

reco.multi.26b<-function(dat,ends_w){
  require(dplyr)
  df<-select(dat,ends_with(ends_w))
  
  reco<-function(var){
    c<-c()
    for(i in 1:length(var)){
      c<-c(c,switch(var[i],"1"=.5,"2"=1.5,"3"=3,"4"=5,0))}
    return(c)
  }
  
  d<-data.frame(df[[1]])
  for(t in 1:ncol(df)){
    d<-data.frame(d,reco(as.character(df[[t]])))
  }
  d<-d[,-1]
  colnames(d)<-paste0("Q",ends_w)
  return(d)
}

q26<-reco.multi.26(dat,ends_26)*reco.multi.26b(dat,ends_2a6b)/7


# Recode 7-9d

reco.multi.79d<-function(dat,ends_w){
  require(dplyr)
  df<-select(dat,ends_with(ends_w))
  
  reco<-function(var){
    c<-c()
    for(i in 1:length(var)){
      c<-c(c,switch(var[i],"1"=1,"2"=0,0))}
    return(c)
  }
  
  d<-data.frame(df[[1]])
  for(t in 1:ncol(df)){
    d<-data.frame(d,reco(as.character(df[[t]])))
  }
  d<-d[,-1]
  colnames(d)<-paste0("Q",ends_w)
  return(d)
}

q79d<-reco.multi.79d(dat,ends_79b)

# Recode Q10

df<-select(dat,ends_with(ends_1010a))
q10<-ifelse(df[[1]]==1,df[[2]]/7,0)
q10[is.na(q10)]<-0

# Calculate score

qall<-cbind(q26,q79d,Q10=q10)

pase.calc.sum<-function(dat,facts=c(20,21,23,23,30,25,25,30,36,20,35,21),dec=sum_dec){
  d<-data.frame(dat[[1]])
  names<-names(dat)
  for(r in 1:ncol(dat)){
    d<-data.frame(d,dat[[r]]*facts[r])}
  d<-d[,-1]
  colnames(d)<-names
  d$sum<-round(rowSums(d),dec)
  return(d)
}

final<-pase.calc.sum(qall,dec=2)

return(final)
}
