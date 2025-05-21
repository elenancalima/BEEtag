
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




library(survival)
library(survminer)
library(GGally)

# Now, refLongData needs to be converted to a format where
# each row is an individual
# and time of death and censoring is recorded

# So, we first repeat each row Total times
# First, we get one row per treatment

refLongData[DaysElapsed==0] -> newFormRefData

# and we need sequences 1:Total for each Treatment, effectively repeating the rows

newFormRefData[,.(iID=(1:Total)), by=.(Treatment)] -> newFormRefData2

# By joining, we have each individual with multiple rows for each day
# But before that, remove NAs

refLongData[newFormRefData2, on=.(Treatment), allow.cartesian = TRUE] -> newFormRefData3

newFormRefData3[!is.na(DaysElapsed)] -> newFormRefData3

# Now, if iID is over Surviving, that means the individual died

newFormRefData3[, Died:=iID>Surviving]

# Now, we need to get the time of death
# which is max(DaysElapsed) with Died==FALSE for each individual

newFormRefData3[, TimeOfDeath:=max(DaysElapsed[!Died]), by=.(Treatment, iID)]

# now, we can have one row per individual again
newFormRefData3[,.(deathTime=1+head(TimeOfDeath,1)),by=.(Treatment, iID)] -> newFormRefData4
newFormRefData4[, notCensored:=deathTime<6]

km <- with(newFormRefData4, Surv(deathTime, notCensored))
head(km,80)
km_fit <- survfit(Surv(deathTime, notCensored) ~ 1, data=newFormRefData4)
summary(km_fit)
autoplot(km_fit)

newFormRefData4[,Treatment:=as.factor(Treatment)]
km_trt_fit <- survfit(Surv(deathTime, notCensored) ~ Treatment, data=newFormRefData4)
summary(km_trt_fit)

kmTrtFitPlot <- function(km_trt_fit){
  data.table(rep(names(km_trt_fit[[10]]),km_trt_fit[[10]]),km_trt_fit[[2]],km_trt_fit[[6]],km_trt_fit[[15]],km_trt_fit[[16]]) -> plotData
  plotData %>% ggplot(aes(x=V2,y=V3, color=as.factor(V1))) +
    geom_line(aes(group=V1)) +
    geom_ribbon(aes(ymin=V4, ymax=V5, group=V1, , fill=as.factor(V1)), alpha=0.2, color=NA) +
    xlab("Days Elapsed") +
    ylab("Survival Probability") +
    ggtitle("Kaplan-Meier") + 
    ylim(0,1) + xlim(min(plotData$V2), max(plotData$V2)) +
    scale_color_discrete(name = "Treatment (n)") +
    theme(legend.position = "bottom")
}

kmTrtFitPlot(km_trt_fit)


newFormRefData4[,TreatmentOrder:=-1*.I]
newFormRefData4[,Treatment:=as.factor(Treatment)]
newFormRefData4[,Treatment:=reorder(Treatment,TreatmentOrder)]
cox <- coxph(Surv(deathTime, notCensored) ~ Treatment, data = newFormRefData4)

survfit(cox, 
        newdata = 
          data.frame(Treatment=levels(newFormRefData4$Treatment))) -> coxFit


coxFitPlot <- function(coxFit){
  coxFit$surv %>% t() %>% as.data.table() -> coxFitTable
  coxFit$lower %>% t() %>% as.data.table() -> coxLowerTable
  coxFit$upper %>% t() %>% as.data.table() -> coxUpperTable
  
  coxFitTable[,Treatment:=levels(newFormRefData4$Treatment)]
  coxLowerTable[,Treatment:=levels(newFormRefData4$Treatment)]
  coxUpperTable[,Treatment:=levels(newFormRefData4$Treatment)]
  
  coxFitTable %>% pivot_longer(cols=1:5, names_to="Time", values_to="SurvivalProbability") -> 
    longerFitTable
  coxLowerTable %>% pivot_longer(cols=1:5, names_to="Time", values_to="LowerBound") ->
    longerLowerTable
  coxUpperTable %>% pivot_longer(cols=1:5, names_to="Time", values_to="UpperBound") ->
    longerUpperTable
  
  longerFitTable %>% setDT() -> longerFitTable
  longerFitTable[,lowerBound:=longerLowerTable$LowerBound]
  longerFitTable[,upperBound:=longerUpperTable$UpperBound]
  longerFitTable[,Time:=coxFit$time[as.numeric(as.factor(longerFitTable$Time))]]
  
  longerFitTable %>% 
    ggplot(aes(x=Time,y=SurvivalProbability, color=as.factor(Treatment))) +
    geom_line(aes(group=Treatment)) +
    geom_ribbon(aes(ymin=lowerBound, ymax=upperBound, 
                    group=Treatment, fill=as.factor(Treatment)), 
                alpha=0.2, color=NA) +
    ggtitle("Cox Proportional Hazards")
}

coxFitPlot(coxFit)

summary(cox)




coxFitTable

View(coxFit)

plot(coxFit$time, coxFit$surv[,1])

survfit(cox, newdata = newFormRefData4[,.(Treatment),by=.(Treatment)][,1])

ggsurvplot(survfit(cox, 
                   newdata = 
                     data.frame(Treatment=unique(newFormRefData4$Treatment)))
           
           newFormRefData4[,.(Treatment),by=.(Treatment)][,1]), 
data=newFormRefData4)




color = "#2E9FDF",
ggtheme = theme_minimal())

plot(cox)
summary(cox)


cox_fit <- survfit(cox, data=newFormRefData4)
cox_fit[[16]]
autoplot(cox_fit)












library(ggplot2)
library(dplyr)
library(ggfortify)

data(veteran)
head(veteran)

km <- with(veteran, Surv(time, status))
head(km,80)

km_fit <- survfit(Surv(time, status) ~ 1, data=veteran)
summary(km_fit, times = c(1,30,60,90*(1:10)))
ggplot2::autoplot(km_fit)

km_trt_fit <- survfit(Surv(time, status) ~ trt, data=veteran)
autoplot(km_trt_fit)


cox <- coxph(Surv(time, status) ~ trt + celltype + karno + 
               diagtime + age + prior , data = veteran)
summary(cox)







