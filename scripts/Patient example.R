#Patient example

## Created from example on https://benalexkeen.com/creating-a-timeline-graphic-using-r-and-ggplot2/

## Manually created dataset
d<-readxl::read_xls("data/enigma_inc_example.xls")

# Columns needed: Time(hh[,.:]mm), Day(index day, number), Person(index person, number), Header(short label)

# Adjustment handles

## Color palette
# mycols<-colors()[c(32,144,31,50,62,91,75,148,367,374,614,633,594,490,645)]
mycols<-rainbow(n=length(unique(d$Person))) # Alternative

## Hoours to include
vis_hours<-24

## Off set levels on the y axis
y_offset_lvls<-7

## Extention of x-axis
x_adj<-10

## Font size
f_size<-9

source("src/timeline_plot.R")

p1
