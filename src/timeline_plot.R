## timeline_plot

# Converting time points to time stamps for labelling
for (i in 1:nrow(d)){
  v<-as.character(d$Time)
  suppressWarnings(d$time_stamp[i]<-ifelse(nchar(unlist(strsplit(v[i],"[.]"))[1])==1,
                                           paste0("0",format(as.numeric(v[i]),nsmall=2)),
                                           format(as.numeric(v[i]),nsmall=2)))
}

# Narmalization of time points for plotting
for (i in 1:nrow(d)){
  v<-as.numeric(unlist(strsplit(d$time_stamp[i],"[,:.]")))
  suppressWarnings(d$time_adj[i]<-(v[1]*60+v[2])*100/60/24+100*(d$Day[i]-1))
}

# Limit the time window
d<-d[d$time_adj<(min(d$time_adj)+(vis_hours*100/24)),]

pos <- c(seq(.1,1,length.out=y_offset_lvls)) # Creating offsets for plotting
positions<-c()
for(i in 1:length(pos)){positions<-c(positions,pos[i],pos[i]*-1)}
# c(0.25,-0.25,0.5, -0.5,0.75,-0.75, 1.0, -1.0,1.25,-1.25, 1.5, -1.5)
directions <- c(1,-1)

line_pos <- data.frame(
  "time_adj"=unique(d$time_adj),
  "position"=rep(positions, length.out=length(unique(d$time_adj))),
  "direction"=rep(directions, length.out=length(unique(d$time_adj)))
)

d <- merge(x=d, y=line_pos, by="time_adj", all = TRUE)

text_offset <- 0.1
d$text_position <- (text_offset * d$direction) + d$position

# pal<-c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") # Color palette
# cbPalette <- head(c(pal,pal,pal),length(unique(d$Person))) # Extending and repeating palette to fit


# Plotting
library(ggplot2)
p1<-ggplot(d,aes(x=time_adj,y=0, col=factor(Person), label=Header))+
  geom_point(aes(y=0), size=5, show.legend = FALSE)+
  geom_text(aes(y=text_position,label=paste0(Header,"; ",time_stamp)),size=f_size, show.legend = FALSE)+
  geom_segment(data=d, aes(y=position,yend=0,xend=time_adj), color='black', size=0.5,alpha=.6) +
  expand_limits(x=c(min(d$time_adj)-x_adj,max(d$time_adj)+x_adj)) +
  theme_classic() +
  scale_colour_manual(values=mycols)+
  geom_hline(yintercept=0,size=.5)+
  theme(axis.line.y=element_blank(),
        axis.text.y=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        axis.ticks.y=element_blank(),
        axis.text.x =element_blank(),
        axis.ticks.x =element_blank(),
        axis.line.x =element_blank())

source("src/remove_all_but.R")
remove_all_but(d,p1)
