## Revision under way.
## CIs still pending.
plot_percentile <- function(ds){

library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)

# Melting df as long format
df_long <- df %>% pivot_longer(cols=-record_id)

# Set x-axis names
domain_names<-c("immediate","visuospatial","verbal","attention","delayed","total")

# Define specific dataframes
df_index <- df_long %>%
  filter(grepl('_is',name)) %>%
  mutate(value=as.numeric(value),
         name=factor(name,labels = domain_names)) 


# df_X95pct <- df_long %>%
#   filter(grepl('X95pct',variable))
# 
# low<-c()
# hgh<-c()
# for (i in 1:nrow(df_X95pct)){
#   low<-c(low,unlist(strsplit(df_X95pct$value[i],"[-]"))[1])
#   hgh<-c(hgh,unlist(strsplit(df_X95pct$value[i],"[-]"))[2])
# }
# df_index<-data.frame(df_index,low=as.numeric(low),high=as.numeric(hgh))

# Correcting odd percentile formatting
# Wonder if this can be done a little more elegantly??
# sel1<-grepl("percentile", df_long$variable)
# # [i,"value"]
# df_long[sel1,"value"]<-ifelse(df_long[sel1,"value"] %in% c("> 99.9",">99.9"),"99.95",
#                               ifelse(df_long[sel1,"value"] %in% c("< 0.1","<0.1"), "0.05", 
#                                      ifelse(df_long[sel1,"value"]%in% c("0,1"),"0.1",
#                                             df_long[sel1,"value"])))

# Percentile dataframe
df_percentile <- df_long %>%
  filter(grepl('_per',name)) %>%
  mutate(value=as.numeric(value),
         name=factor(name,labels = domain_names)) 


# Plotting index scores
# index_plot<-ggplot(data=df_index, aes(x=name, y=value, color=factor(record_id), group=factor(record_id))) + 
#   geom_point() +
#   # geom_errorbar(width=0.05,aes(ymin = low,
#   #                   ymax = high)) + 
#   geom_path() +
#   expand_limits(y=c(40,160)) +
#   scale_y_continuous(breaks=seq(40,160,by=10)) +
#   ylab("Index Score") + 
#   # geom_hline(yintercept=100) + # Expected average
#   labs(colour = "ID") +
#   theme(axis.title.x=element_blank(),
#         axis.text.x=element_blank(),
#         axis.ticks.x=element_blank())

# Plotting percentiles
percentile_plot<-ggplot(data=df_percentile, aes(x=name, y=value, fill=factor(record_id)))+
  geom_col(position = "dodge") +
  expand_limits(y=c(0,100)) +
  scale_y_continuous(breaks=seq(0,100,by=10)) +
  xlab("Cognitive domains") +
  ylab("Percentile") + 
  # geom_hline(yintercept=50) + # Expected average
  labs(fill = "ID")

return(percentile_plot)
}

