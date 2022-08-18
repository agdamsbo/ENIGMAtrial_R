## -----------------------------------------------------------------------------
## Cognitive Index app
## -----------------------------------------------------------------------------
## 
## Shiny app to do Cognitive Index look up based on raw scores.
## 
## This is just the main script for local test and deployment
## 
## 
## Wish list
## - First run only inputs single numbers
## - How about uploading dataset? https://shiny.rstudio.com/articles/upload.html
## - And then download: https://shiny.rstudio.com/articles/download.html


setwd("/Users/au301842/ENIGMAtrial_R/apps/Index app")
shiny::runApp()


source("app/app_deploy.R")


setwd("/Users/au301842/ENIGMAtrial_R")
