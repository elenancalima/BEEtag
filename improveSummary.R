
Sys.setlocale("LC_ALL", "English")
library(tidyverse)
library(data.table)

read.csv("improveSummary.csv") %>% setDT() -> improveData

colnames(improveData)[1] <- "TimePoint"

improveData[,Date:=gsub("_[a-zA-Z]+","",TimePoint)]
improveData[,TimeCriteria:=gsub("[0-9A-Z]+_","",TimePoint)]



improveData %>% ggplot(aes(x=Stage,y=PerHour)) +
  geom_line(aes(color=TimeCriteria, group=TimeCriteria)) +
  ylim(0,25) + facet_wrap(~Date, ncol=2)

