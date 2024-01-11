plot_index <- function(ds,id="record_id",sub_plot="_is",scores=c("_is","_lo","_up","_per"),dom_names=c("immediate","visuospatial","verbal","attention","delayed","total"),facet.by=NULL){

  # id colname  of id column. Base for colouring
  # ds data frame
  # sub_plot column subset to plot
  # scores name bits of score variables
  # dom_names domain names
  # facet.by variable to base facet_grid on.

# library(ggplot2)
# library(dplyr)
# library(tidyr)
 
  df_plot<-ds|>
    dplyr::select(c(id,
             facet.by,
             tidyselect::ends_with(scores)))|>
    tidyr::pivot_longer(cols=-c(id,facet.by))|>
    subset(grepl(sub_plot,name))|>
    dplyr::mutate(value=suppressWarnings(as.numeric(value)),
           name=factor(name,labels = dom_names))
  
  if (!is.null(facet.by)){
    colnames(df_plot)<-c("id","facet","name","value")
  } else {
    colnames(df_plot)<-c("id","name","value")
  }



if (sub_plot=="_is"){
  index_plot<-df_plot|>
    ggplot2::ggplot(ggplot2::aes(x=name, y=value, color=factor(id), group=factor(id))) + 
    ggplot2::geom_point() +
    ggplot2::geom_path() +
    ggplot2::expand_limits(y=c(40,160)) +
    ggplot2::scale_y_continuous(breaks=seq(40,160,by=10)) +
    ggplot2::ylab("Index Score") +
    ggplot2::xlab("Domain")+
    ggplot2::labs(colour = "ID")
}

if (sub_plot=="_per"){
  index_plot<-df_plot|>
    ggplot2::ggplot(ggplot2::aes(x=name, y=value, fill=factor(id)))+
    ggplot2::geom_col(position = "dodge") +
    ggplot2::expand_limits(y=c(0,100)) +
    ggplot2::scale_y_continuous(breaks=seq(0,100,by=10)) +
    ggplot2::xlab("Cognitive domains") +
    ggplot2::ylab("Percentile") + 
    ggplot2::labs(fill = "ID")
}

if (!is.null(facet.by)){
  index_plot + ggplot2::facet_grid(cols=vars(facet)) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1)) 
    
} else {
  index_plot
}

}

plot_index2 <- function(ds, ...){
  require(patchwork)
  plot_index(ds)/plot_index(ds,sub_plot = "_per")
}
