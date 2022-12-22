# Visuals
library(lubridate)

d <- d[with(d, order(record_id)), ]

trend_line<-data.frame(number=c(1,as.numeric(difftime(d$incl_date[nrow(d)],d$incl_date[1],units = "weeks"))),
                       date=c(d$incl_date[1],d$incl_date[nrow(d)]))

trend_line_eos <- data.frame(number=trend_line[1],
                        date=(trend_line[2]+365))

p1<-ggplot(data = d, aes(x = incl_date, y = record_id))+
  geom_line(color = "#00AFBB", size = 2)+
  scale_x_date(date_breaks = "1 month",date_labels = "%b/%Y")+
  xlab("Inclusion date")+
  ylab("Number of included patients")+
  geom_line(data=trend_line,aes(x=date,y=number))


dt<-d[is.na(d$eos2),]
dt$non_eeos<-as.numeric(seq(dt$record_id))

p2<-ggplot(data = dt, aes(x = incl_date, y = non_eeos))+
  geom_line(color = "#00AFBB", size = 2)+
  scale_x_date(date_breaks = "1 month",date_labels = "%b/%Y")+
  xlab("Inclusion date")+
  ylab("Number of included patients")+
  geom_line(data=trend_line_eos,aes(x=date,y=number))
