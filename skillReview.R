
Sys.setlocale("LC_ALL", "English")
library(tidyverse)
library(data.table)

read.csv("skillBuilding.csv") %>% setDT() -> skillData
colnames(skillData)[1] <- "Week"
 

skillData[Week=="Week3"] %>% ggplot(aes(x=DaysElapsed, y=Survival)) +
  geom_line(aes(group=Tagger, color=Tagger))


skillData[Week=="Week4"] %>% ggplot(aes(x=DaysElapsed, y=Survival)) +
  geom_line(aes(group=Tagger, color=Tagger))



skillData %>% ggplot(aes(x=DaysElapsed, y=Survival)) +
  geom_line(aes(group=Tagger, color=Tagger)) + facet_grid(~Week, scales = "free") +
  ylim(0, 60) + ggtitle("Skill building discrepancy")
