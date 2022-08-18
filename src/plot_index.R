plot_index <- function(ds,id="record_id",sub_plot="_is",dom_names=c("immediate","visuospatial","verbal","attention","delayed","total")){

  # id colname  of id column
  # ds data frame
  # sub_plot column subset to plot
  # dom_names domain names

library(ggplot2)
library(dplyr)
library(tidyr)

  colnames(ds[id])<-"record_id"
  
# Set x-axis names


df_plot<-df|>
  pivot_longer(cols=-record_id)|>
  subset(grepl(sub_plot,name))|>
  mutate(value=as.numeric(value),
         name=factor(name,labels = dom_names))

if (sub_plot=="_is"){
  index_plot<-df_plot|>
    ggplot(aes(x=name, y=value, color=factor(record_id), group=factor(record_id))) + 
  geom_point() +
  geom_path() +
  expand_limits(y=c(40,160)) +
  scale_y_continuous(breaks=seq(40,160,by=10)) +
  ylab("Index Score") +
  xlab("Domain")+
  # geom_hline(yintercept=100) + # Expected average
  labs(colour = "ID")
}

if (sub_plot=="_per"){
  index_plot<-df_plot|>
    ggplot(aes(x=name, y=value, fill=factor(record_id)))+
    geom_col(position = "dodge") +
    expand_limits(y=c(0,100)) +
    scale_y_continuous(breaks=seq(0,100,by=10)) +
    xlab("Cognitive domains") +
    ylab("Percentile") + 
    # geom_hline(yintercept=50) + # Expected average
    labs(fill = "ID")
}

return(plot(index_plot))
}

