## -----------------------------------------------------------------------------
## HWE Calc test app deployment
## -----------------------------------------------------------------------------
## 
## This app was written as proof of concept for my Research year program, 
## as no online calculators were found to calculate the 
## Hardy-Weinberg-equilibrium of allele distributions.
## 
## Source: https://raw.githubusercontent.com/agdamsbo/daDoctoR/master/R/hwe_geno.R
## 
## /AG Damsbo 
## 

setwd("/Users/au301842/ENIGMAtrial_R/apps/HWE Calc")
shiny::runApp()

source("app/app_deploy.R")

setwd("/Users/au301842/ENIGMAtrial_R")
