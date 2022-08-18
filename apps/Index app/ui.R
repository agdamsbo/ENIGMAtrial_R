library(shiny)
library(ggplot2)

source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/index_from_raw.R")

ui <- fluidPage(
  
  # Application title
  titlePanel("Calculating cognitive index scores in multidimensional testing. Single entry."),
  
  sidebarPanel(
      h4("Test results"),
      
      numericInput(inputId = "age",
                   label = "Age",
                   value=60),
      
      radioButtons(inputId = "ver",
                   label = "Test version (A/B)",
                   inline = FALSE,
                   choiceNames=c("A",
                                 "B"),
                   choiceValues=c(1,2)),
      
      numericInput(inputId = "rs1",
                   label = "Immediate memory",
                   value=35),
      numericInput(inputId = "rs2",
                   label = "Visuospatial functions",
                   value=20),
      numericInput(inputId = "rs3",
                   label = "Verbal functions",
                   value=30),
      numericInput(inputId = "rs4",
                   label = "Attention",
                   value=20),
      numericInput(inputId = "rs5",
                   label = "Delayed memory",
                   value=40)
      ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Summary",
                 h3("Index Scores"),

                 htmlOutput("ndx.tbl", container = span),
                 
                 h3("Percentiles"),
                 
                 htmlOutput("per.tbl", container = span)
    ),
    tabPanel("Plots",
             h3("Index Scores"),

             plotOutput("ndx.plt"),

             h3("Percentiles"),

             plotOutput("ndx.plt")
    )
    
    ))
        #,
        
        # tabPanel("Calculations",
        #          
        #          h3(textOutput("chi", container = span)),
        #          htmlOutput("chi.val", container = span),
        #          
        #          h3(textOutput("p", container = span)),
        #          htmlOutput("p.val", container = span),
        #          
        #          value=2),
        # 
        # 
        # 
        # tabPanel("Plots",
        #          h3(textOutput("geno.pie.ttl", container = span)),
        #          plotOutput("geno.pie.plt"),
        #          
        #          value=3),
        # selected= 2, type = "tabs")
)
