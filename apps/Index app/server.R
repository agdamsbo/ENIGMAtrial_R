server <- function(input, output, session) {
  library(dplyr)
  library(ggplot2)
  library(tidyr)
  source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/plot_index.R")
  source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/index_from_raw.R")

  dat<-reactive({
    
    df<-data.frame(record_id="1",
                   ab=input$version,
                   age=input$age,
                   imm=input$rs1,
                   vis=input$rs2,
                   ver=input$rs3,
                   att=input$rs4,
                   del=input$rs5,
                   stringsAsFactors = FALSE)
    return(df)
  })

  dat_u<-reactive({
  # input$file1 will be NULL initially. After the user selects
  # and uploads a file, head of that data file by default,
  # or all rows if selected, will be shown.
  
  
  req(input$file1)
  
  df <- read.csv(input$file1$datapath,
                 header = input$header,
                 sep = input$sep,
                 quote = input$quote)
  
  return(df)
  })
  
  dat_f<-reactive({
    
    if (input$type==1){
      return(dat())}
    if (input$type==2){
      return(head(dat_u(),10))}
  })
  
  index_p <- reactive({ index_from_raw(ds=dat_f(),
                                          indx=read.csv("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/data/index.csv"),
                                          version = dat_f()$ab,
                                          age = dat_f()$age,
                                          raw_columns=c("imm","vis","ver","att","del")) })

  
  output$ndx.tbl <- renderTable({ 
    index_p()|>
      select("id",contains("_is"))
    })
  
  output$per.tbl <- renderTable({
    index_p()|>
      select("id",contains("_per"))
  })
  
  
  output$ndx.plt<-renderPlot({

    plot_index(index_p(),sub_plot = "_is")
  })

  output$per.plt<-renderPlot({
    plot_index(index_p(),sub_plot = "_per")
  })
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = "index_lookup.csv",
    
    content = function(file) {
      write.csv(index_p(), file, row.names = FALSE)
    }
  )
  
}
