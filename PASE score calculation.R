# Calculating the pase score including subscores from dataset provided from REDCap.
## A dataset of real world data is provided as an example.

source("src/pase_calc.R")

pase_sample<-read.csv("src/pase.csv")
# colnames(pase_sample)

pase_score<-pase_calc(pase_sample,ends_26 = c("02","03","04","05","06"),
          ends_2a6b = c("02a","03b","04b","05b","06b"), 
          ends_79b = c("07","08","09a","09b","09c","09d"), 
          ends_1010a = c("10","10a"))

show(head(round(pase_score,0),20))
