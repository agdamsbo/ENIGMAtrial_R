server <- function(input, output, session) {
  library(dplyr)

  dat<-reactive({
    data.frame(record_id="1",
               imm=input$rs1,
               vis=input$rs2,
               ver=input$rs3,
               att=input$rs4,
               del=input$rs5,
               stringsAsFactors = FALSE)

  })

  
  index_p <- function() ({ index_from_raw(ds=dat(),
                                          indx=read.csv("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/data/index.csv"),
                                          version = input$ver,
                                          age = input$age,
                                          raw_columns=c("imm","vis","ver","att","del")) })

  
  output$ndx.tbl <- renderTable({ 
    index_p()|>
      select(contains("_is"))
    })
  
  output$per.tbl <- renderTable({
    index_p()|>
      select(contains("_per"))
  })
  
  output$ndx.plt<-renderPlot({
    source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/plot_index.csv")
    plot_index(dat())
  })

  output$per.plt<-renderPlot({
    source("https://raw.githubusercontent.com/agdamsbo/ENIGMAtrial_R/main/src/plot_percentile.csv")
    plot_percentile(dat())
  })
}
