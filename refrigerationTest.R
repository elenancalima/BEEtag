
Sys.setlocale("LC_ALL", "English")
library(tidyverse)
library(data.table)

read.csv("refrigerationShort.csv") %>% setDT() -> refShortData

colnames(refShortData)[1] <- "Treatment"

refShortData[,AwakeProportion:=Awake/Total]
refShortData[,Treatment:=paste0(Treatment," (n=",Total,")")]

refShortData %>% 
  ggplot(aes(x=TimeElapsed,y=AwakeProportion, color=as.factor(Treatment))) +
  geom_line(aes(group=Treatment)) +
  xlab("Time Elapsed (min)") +
  ggtitle("Short-term effect of refrigeration") 



read.csv("refrigerationLong.csv") %>% setDT() -> refLongData
colnames(refLongData)[1] <- "Treatment"
refLongData[,SurvivingProportion:=Surviving/Total]
refLongData[,Treatment:=paste0(Treatment," (n=",Total,")")]

refLongData %>% 
  ggplot(aes(x=DaysElapsed,y=SurvivingProportion, color=as.factor(Treatment))) +
  geom_line(aes(group=Treatment)) +
  xlab("Days Elapsed") +
  ggtitle("Long-term effect of refrigeration") + 
  ylim(0,1) + xlim(0, 5)




