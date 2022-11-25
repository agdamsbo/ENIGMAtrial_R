plot_index <- function(ds,id="record_id",sub_plot="_is",scores=c("_is","_lo","_up","_per"),dom_names=c("immediate","visuospatial","verbal","attention","delayed","total"),facet.by=NULL){

  # id colname  of id column. Base for colouring
  # ds data frame
  # sub_plot column subset to plot
  # dom_names domain names
  # facet.by variable to base facet_grid on.

library(ggplot2)
library(dplyr)
library(tidyr)
 
  df_plot<-ds|>
    select(c(id,
             facet.by,
             ends_with(scores)))|>
    pivot_longer(cols=-c(id,facet.by))|>
    subset(grepl(sub_plot,name))|>
    mutate(value=as.numeric(value),
           name=factor(name,labels = dom_names))
  
  if (!is.null(facet.by)){
    colnames(df_plot)<-c("id","facet","name","value")
  } else {
    colnames(df_plot)<-c("id","name","value")
  }



if (sub_plot=="_is"){
  index_plot<-df_plot|>
    ggplot(aes(x=name, y=value, color=factor(id), group=factor(id))) + 
  geom_point() +
  geom_path() +
  expand_limits(y=c(40,160)) +
  scale_y_continuous(breaks=seq(40,160,by=10)) +
  ylab("Index Score") +
  xlab("Domain")+
  labs(colour = "ID")
}

if (sub_plot=="_per"){
  index_plot<-df_plot|>
    ggplot(aes(x=name, y=value, fill=factor(id)))+
    geom_col(position = "dodge") +
    expand_limits(y=c(0,100)) +
    scale_y_continuous(breaks=seq(0,100,by=10)) +
    xlab("Cognitive domains") +
    ylab("Percentile") + 
    labs(fill = "ID")
}

if (!is.null(facet.by)){
  index_plot + facet_grid(cols=vars(facet)) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
    
} else {
  index_plot
}

}

