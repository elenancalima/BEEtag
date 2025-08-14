
Sys.setlocale("LC_ALL", "English")
library(tidyverse)
library(data.table)

read.csv("tagMethodReport.csv") %>% setDT() -> tagData

colnames(tagData)[1] <- "Attempts"

tagData[,X2hTagIntact:=Ants-X2hDetach]

tagData[Glue=="GelSuper" & Production=="Individual"] -> refData

refData[,.(Ants=sum(Ants),
           TagIntact2h=sum(X2hTagIntact),
           Survival2h=sum(X2hSurvival),
           Survival3d=sum(X3dCorrSurvival)),by=.(PostTreat)] ->
  refSummary

refSummary[,tagIntactCI95L:=binom.test(x=TagIntact2h,n=Ants,p=(sum(refSummary$TagIntact2h)/sum(refSummary$Ants)))$conf.int[1],by=PostTreat]
refSummary[,tagIntactCI95U:=binom.test(x=TagIntact2h,n=Ants,p=(sum(refSummary$TagIntact2h)/sum(refSummary$Ants)))$conf.int[2],by=PostTreat]

refSummary[,survivalCI95L:=binom.test(x=Survival2h,n=Ants,p=(sum(refSummary$Survival2h)/sum(refSummary$Ants)))$conf.int[1],by=PostTreat]
refSummary[,survivalCI95U:=binom.test(x=Survival2h,n=Ants,p=(sum(refSummary$Survival2h)/sum(refSummary$Ants)))$conf.int[2],by=PostTreat]

refSummary[,survival3dCI95L:=binom.test(x=Survival3d,n=Ants,p=(sum(refSummary$Survival3d)/sum(refSummary$Ants)))$conf.int[1],by=PostTreat]
refSummary[,survival3dCI95U:=binom.test(x=Survival3d,n=Ants,p=(sum(refSummary$Survival3d)/sum(refSummary$Ants)))$conf.int[2],by=PostTreat]

refSummary[,Survival3dRatio:=Survival3d/Ants]
refSummary[,Survival2hRatio:=Survival2h/Ants]
refSummary[,TagIntact2hRatio:=TagIntact2h/Ants]

refSummary[,PostTreat:=reorder(PostTreat, .I)]

refSummary %>% 
  ggplot(aes(x=PostTreat,y=TagIntact2hRatio)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=tagIntactCI95L, ymax=tagIntactCI95U), width=.2) +
  xlab("Post-treatment") +
  ylab("Proportion of tag intact after 2h") +
  ggtitle("Tag integrity after 2h") + 
  ylim(0,1)

refSummary %>%
  ggplot(aes(x=PostTreat,y=Survival2hRatio)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=survivalCI95L, ymax=survivalCI95U), width=.2) +
  xlab("Post-treatment") +
  ylab("Proportion of ants alive after 2h") +
  ggtitle("Ant survival after 2h") + 
  ylim(0,1)

refSummary %>%
  ggplot(aes(x=PostTreat,y=Survival3dRatio)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=survival3dCI95L, ymax=survival3dCI95U), width=.2) +
  xlab("Post-treatment") +
  ylab("Proportion of ants alive after 3d") +
  ggtitle("Ant survival after 3d") + 
  ylim(0,1)




tagData[1:12][Glue=="GelSuper"] -> puttyData

puttyData[,.(Attempts=sum(Attempts),
           GlueSuccess=sum(Ants)),by=.(TagPick)] ->
  puttySummary

puttySummary[,GlueSuccessRatio:=GlueSuccess/Attempts]
puttySummary[,GlueSuccessCI95L:=binom.test(x=GlueSuccess,n=Attempts,p=(sum(puttySummary$GlueSuccess)/sum(puttySummary$Attempts)))$conf.int[1],by=TagPick]
puttySummary[,GlueSuccessCI95U:=binom.test(x=GlueSuccess,n=Attempts,p=(sum(puttySummary$GlueSuccess)/sum(puttySummary$Attempts)))$conf.int[2],by=TagPick]

puttySummary %>% 
  ggplot(aes(x=TagPick,y=GlueSuccessRatio)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=GlueSuccessCI95L, ymax=GlueSuccessCI95U), width=.2) +
  xlab("Tag pick") +
  ylab("Proportion of successful glue application") +
  ggtitle("Glue application success") + 
  ylim(0,1)


tagData[1:12] -> prodData
prodData[,.(Ants=sum(Ants),
            TagIntact2h=sum(X2hTagIntact),
           Survival2h=sum(X2hSurvival),
           Survival3d=sum(X3dCorrSurvival)),by=.(Production,PostTreat)]-> prodSummary

prodSummary[,tagIntactCI95L:=binom.test(x=TagIntact2h,n=Ants,p=(sum(prodSummary$TagIntact2h)/sum(prodSummary$Ants)))$conf.int[1],by=.(Production,PostTreat)]
prodSummary[,tagIntactCI95U:=binom.test(x=TagIntact2h,n=Ants,p=(sum(prodSummary$TagIntact2h)/sum(prodSummary$Ants)))$conf.int[2],by=.(Production,PostTreat)]
prodSummary[,survivalCI95L:=binom.test(x=Survival2h,n=TagIntact2h,p=(sum(prodSummary$Survival2h)/sum(prodSummary$TagIntact2h)))$conf.int[1],by=.(Production,PostTreat)]
prodSummary[,survivalCI95U:=binom.test(x=Survival2h,n=TagIntact2h,p=(sum(prodSummary$Survival2h)/sum(prodSummary$TagIntact2h)))$conf.int[2],by=.(Production,PostTreat)]
prodSummary[,survival3dCI95L:=binom.test(x=Survival3d,n=Survival2h,p=(sum(prodSummary$Survival3d)/sum(prodSummary$Survival2h)))$conf.int[1],by=.(Production,PostTreat)]
prodSummary[,survival3dCI95U:=binom.test(x=Survival3d,n=Survival2h,p=(sum(prodSummary$Survival3d)/sum(prodSummary$Survival2h)))$conf.int[2],by=.(Production,PostTreat)]
prodSummary[,Survival2hRatio:=Survival2h/TagIntact2h]
prodSummary[,TagIntact2hRatio:=TagIntact2h/Ants]
prodSummary[,Survival3dRatio:=Survival3d/Survival2h]

prodSummary[,Treatment:=paste0(PostTreat, "_", Production)]
prodSummary[,Treatment:=reorder(Treatment, .I)]
  
prodSummary %>% 
  ggplot(aes(x=Treatment,y=TagIntact2hRatio, fill=Production)) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=tagIntactCI95L, ymax=tagIntactCI95U), width=0.2, position="dodge") +
  xlab("Post-treatment") +
  ylab("Proportion of tag intact after 2h") +
  ggtitle("Tag integrity after 2h") + 
  ylim(0,1)

prodSummary %>%
  ggplot(aes(x=Treatment,y=Survival2hRatio, fill=Production)) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=survivalCI95L, ymax=survivalCI95U), width=0.2, position="dodge") +
  xlab("Post-treatment") +
  ylab("Proportion of tag-intact ants alive after 2h") +
  ggtitle("Tag-intact ant survival after 2h") + 
  ylim(0,1)

prodSummary %>%
  ggplot(aes(x=Treatment,y=Survival3dRatio, fill=Production)) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=survival3dCI95L, ymax=survival3dCI95U), width=.2, position="dodge") +
  xlab("Post-treatment") +
  ylab("Proportion of 2h-surviving ants still alive after 3d") +
  ggtitle("3d survival rate of 2h-survival Ants") + 
  ylim(0,1)




tagData[13:15] -> glueData

glueData[,.(Ants=sum(Ants),
            TagIntact2h=sum(X2hTagIntact),
            Survival2h=sum(X2hSurvival),
            Survival3d=sum(X3dCorrSurvival),
            correctPos=sum(X2hCorrSurvival)),by=.(Glue)]-> glueSummary

glueSummary[,tagIntactCI95L:=binom.test(x=TagIntact2h,n=Ants,p=(sum(glueSummary$TagIntact2h)/sum(glueSummary$Ants)))$conf.int[1],by=Glue]
glueSummary[,tagIntactCI95U:=binom.test(x=TagIntact2h,n=Ants,p=(sum(glueSummary$TagIntact2h)/sum(glueSummary$Ants)))$conf.int[2],by=Glue]
glueSummary[,survivalCI95L:=binom.test(x=Survival2h,n=TagIntact2h,p=(sum(glueSummary$Survival2h)/sum(glueSummary$TagIntact2h)))$conf.int[1],by=Glue]
glueSummary[,survivalCI95U:=binom.test(x=Survival2h,n=TagIntact2h,p=(sum(glueSummary$Survival2h)/sum(glueSummary$TagIntact2h)))$conf.int[2],by=Glue]
glueSummary[,survival3dCI95L:=binom.test(x=Survival3d,n=Survival2h,p=(sum(glueSummary$Survival3d)/sum(glueSummary$Survival2h)))$conf.int[1],by=Glue]
glueSummary[,survival3dCI95U:=binom.test(x=Survival3d,n=Survival2h,p=(sum(glueSummary$Survival3d)/sum(glueSummary$Survival2h)))$conf.int[2],by=Glue]
glueSummary[,correctPosCI95L:=binom.test(x=correctPos,n=TagIntact2h,p=(sum(glueSummary$correctPos)/sum(glueSummary$TagIntact2h)))$conf.int[1],by=Glue]
glueSummary[,correctPosCI95U:=binom.test(x=correctPos,n=TagIntact2h,p=(sum(glueSummary$correctPos)/sum(glueSummary$TagIntact2h)))$conf.int[2],by=Glue]

glueSummary[,Survival2hRatio:=Survival2h/TagIntact2h]
glueSummary[,TagIntact2hRatio:=TagIntact2h/Ants]
glueSummary[,Survival3dRatio:=Survival3d/Survival2h]
glueSummary[,correctPosRatio:=correctPos/TagIntact2h]
glueSummary[,Glue:=reorder(Glue, c(2,3,1))]

glueSummary %>% 
  ggplot(aes(x=Glue,y=TagIntact2hRatio)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=tagIntactCI95L, ymax=tagIntactCI95U), width=.2) +
  xlab("Glue") +
  ylab("Proportion of tag intact after 2h") +
  ggtitle("Tag integrity after 2h") + 
  ylim(0,1)

glueSummary %>%
  ggplot(aes(x=Glue,y=Survival2hRatio)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=survivalCI95L, ymax=survivalCI95U), width=.2) +
  xlab("Glue") +
  ylab("Proportion of tag-intact ants alive after 2h") +
  ggtitle("Tag-intact ant survival after 2h") + 
  ylim(0,1)

glueSummary %>%
  ggplot(aes(x=Glue,y=Survival3dRatio)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=survival3dCI95L, ymax=survival3dCI95U), width=.2) +
  xlab("Glue") +
  ylab("Proportion of 2h-surviving ants alive after 3d") +
  ggtitle("2h-surviving ant alive after 3d") +
  ylim(0,1)

glueSummary %>%
  ggplot(aes(x=Glue,y=correctPosRatio)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=correctPosCI95L, ymax=correctPosCI95U), width=.2) +
  xlab("Glue") +
  ylab("Proportion of correct tag position") +
  ggtitle("Tag position correctness") + 
  ylim(0,1)

glueSummary[,.(Glue,Ants,TagIntact2h,Survival2h,correctPos,Survival3d)]




