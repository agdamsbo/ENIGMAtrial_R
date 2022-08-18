source("https://raw.githubusercontent.com/agdamsbo/daDoctoR/master/R/hwe_geno.R")

library(shiny)
library(ggplot2)

ui <- fluidPage(
  
  # Application title
  titlePanel("Chi square test of HWE for bi- or triallelic systems"),
  
  sidebarLayout(
    sidebarPanel(
      
      # Input: Numeric entry for number of alleles ----
      radioButtons(inputId = "ale",
                   label = "Number of alleles:",
                   inline = FALSE,
                   choiceNames=c("Two alleles (M, N)",
                                 "Three alleles (M, N, O)"),
                   choiceValues=c(2,3)),
      
      h4("Observed genotype distribution"),
      
      numericInput(inputId = "mm",
                   label = "MM:",
                   value=NA),
      
      numericInput(inputId = "mn",
                   label = "MN:",
                   value=NA),
      
      numericInput(inputId = "nn",
                   label = "NN:",
                   value=NA),
      conditionalPanel(condition = "input.ale==3",
                       
                       numericInput(inputId = "mo",
                                    label = "MO:",
                                    value=NA),
                       
                       numericInput(inputId = "no",
                                    label = "NO:",
                                    value=NA),
                       
                       numericInput(inputId = "oo",
                                    label = "OO:",
                                    value=NA))
      
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Summary",
                 h3(textOutput("obs.dist", container = span)),
                 htmlOutput("obs.tbl", container = span),
                 
                 h3(textOutput("exp.dist", container = span)),
                 htmlOutput("exp.tbl", container = span),
                 
                 h3(textOutput("allele.dist", container = span)),
                 htmlOutput("allele.tbl", container = span),
                 
                 value=1),
        
        tabPanel("Calculations",
                 
                 h3(textOutput("chi", container = span)),
                 htmlOutput("chi.val", container = span),
                 
                 h3(textOutput("p", container = span)),
                 htmlOutput("p.val", container = span),
                 
                 value=2),
        
        
        
        tabPanel("Plots",
                 h3(textOutput("geno.pie.ttl", container = span)),
                 plotOutput("geno.pie.plt"),
                 
                 value=3),
        selected= 2, type = "tabs")
    )
  )
)
