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

source("/Users/au301842/ENIGMAtrial_R/apps/app_deploy.R")

setwd("/Users/au301842/ENIGMAtrial_R")

## Poor mans changelog

## 18aug2022 Its alive!!
## https://cognitiveindex.shinyapps.io/index_app/

## 19aug2022
## Now live with a choice between single entry or file upload, and download option for results in both cases.
## Still missing is a better labelling, however this works for now.
