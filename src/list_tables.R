list_tables<-function(table_paths,sheets=2,include_all=TRUE){
  # Sheets denotes the number of sheets to import. At the moment only the amount can be specified, not a range or specific sheets. Its on the list!
  # This might be shortened inspired by this thread: https://stackoverflow.com/questions/9564489/read-all-files-in-a-folder-and-apply-a-function-to-each-data-frame
  require(readxl)
  
  paths<-table_paths
  tbls<-list()
  table_names<-c()
  
  for(i in 1:length(paths)){
    path<-paths[i]
    table_name<-paste0("index_",unlist(strsplit(rev(unlist(strsplit(paths[i], "[/]")))[1], "[.]"))[1])
    table_names<-c(table_names,table_name)
    index_domain<-list()
    
    if (include_all==TRUE){
      t_shts<-length(excel_sheets(path))
      for(x in 1:t_shts) {
        shts<-1:t_shts
        index_domain[[excel_sheets(path)[x]]] <- data.frame(read_excel(path=path, sheet=shts[x]))
      }
    }
    
    if (include_all==FALSE){
      for(x in 1:sheets) {
        shts<-1:sheets
        index_domain[[excel_sheets(path)[x]]] <- data.frame(read_excel(path=path, sheet=shts[x]))
      }
    }
    tbls<-append(tbls,list(index_domain))
  }
  names(tbls)<-table_names
  
  return(tbls)
  
  # The read_excel function guesses the data type. If clear definition is needed, this can be added:
  # ,col_types = c("numeric","numeric","text","text","text","text")
  # In R version >4 stringAsfactor is FALSE as default.
  # The "read_excel" also works with both .xls and .xlsx. The first is much faster though!
}
