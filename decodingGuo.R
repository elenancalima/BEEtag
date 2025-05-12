
Sys.setlocale("LC_ALL", "English")
library(tidyverse)
library(data.table)
library(stringr)

source("cornerDiagFunctions.R")

read.csv("Calibration-1-18-1.csv") %>% setDT() -> calData

read.csv("AntTrackAggregateUpdated-1-18-1.csv") %>% setDT() -> antData

# let's assume that Var1 Var2 are centers

# and we have 5 pairs of additional coordinates, from Var4 to Var13.

# and we have 'order' information in 4 columns, Var14 to Var17.

# In Guo's Matlab code, we see this array frequently:
# 'x_cor' 'y_cor' 'number' 'frontX' 'frontY' 'corners1' 'corners2' 'corners3' 'corners4' 'corners5' 'corners6' 'corners7' 'corners8' 'order1' 'order2' 'order3' 'order4'

# In that case, it is reasonable to assume that the 'front' is a special coordinate
# that is not affected by the 'order.' 


# Assume that Var4 Var5 are fronts

antData[,centerX:=Var1]
antData[,centerY:=Var2]

antData[,frontX:=Var4]
antData[,frontY:=Var5]

diagnoseAssumption(antData)

# Okay. looks reasonable...?


diagnoseAssumption(antData, diagData=TRUE) -> goodData
goodData[,orderString:=paste0(Var14, Var15, Var16, Var17)]
goodData$orderString %>% unique()

goodData[,corner1pos:=str_locate(orderString, "1")[,1]]
goodData[,corner1X:=c(Var7, Var9, Var11, Var13)[corner1pos]]
goodData[,corner1Y:=c(Var6, Var8, Var10, Var12)[corner1pos]]

goodData[,corner2pos:=str_locate(orderString, "2")[,1]]
goodData[,corner2X:=c(Var7, Var9, Var11, Var13)[corner2pos]]
goodData[,corner2Y:=c(Var6, Var8, Var10, Var12)[corner2pos]]

goodData[,corner3pos:=str_locate(orderString, "3")[,1]]
goodData[,corner3X:=c(Var7, Var9, Var11, Var13)[corner3pos]]
goodData[,corner3Y:=c(Var6, Var8, Var10, Var12)[corner3pos]]

goodData[,corner4pos:=str_locate(orderString, "4")[,1]]
goodData[,corner4X:=c(Var7, Var9, Var11, Var13)[corner4pos]]
goodData[,corner4Y:=c(Var6, Var8, Var10, Var12)[corner4pos]]


goodData[] %>% ggplot() +
  geom_point(aes(x=(corner1X - xCor_center), y=corner1Y - yCor_center, color = orderString))

goodData[] %>% ggplot() +
  geom_point(aes(x=(corner1X - xCor_center), y=centerToFrontAngle, color = orderString))

goodData[] %>% ggplot() +
  geom_point(aes(x=(corner1Y - yCor_center), y=centerToFrontAngle, color = orderString))


goodData[] %>% ggplot() +
  geom_point(aes(x=1:nrow(goodData), y=centerToFrontAngle, color = orderString))

             

goodData[,orderString:=reorder(orderString, centerToFrontAngle)]

goodData[] %>% ggplot() +
  geom_point(aes(x=orderString, y=centerToFrontAngle))




goodData[] %>% ggplot() +
  geom_point(aes(x=(corner1Y - yCor_center), y=centerToFrontAngle, color = orderString))





, color='black')


+
  geom_point(aes(x=(corner2X - xCor_center), y=centerToFrontAngle), color='black')) +
  facet_wrap(~ID)



# We also wanted to see if a corner defined by a specific order
# is consistent within the individual.
antData[,orderSeries:=paste0(Var14, Var15, Var16, Var17)]
antData[,corner1pos:=str_locate(orderSeries, "1")[,1]]
antData[,frontX:=c(Var7, Var9, Var11, Var13)[corner1pos]]
antData[,frontY:=c(Var6, Var8, Var10, Var12)[corner1pos]]
antData[,orderString:=paste0(Var14, Var15, Var16, Var17)]
diagnoseAssumption(antData)



diagnoseAssumption(antData[orderString == "2314"])
diagnoseAssumption(antData[Var4 < centerX & Var5 > centerY])

& orderString == "2314"] )
diagnoseAssumption(antData[frontX < centerX])

# it is sorta chaotic and unlikely to be a good assumption.



# Maybe the 4 pairs are in the reverse order?

antData[,frontX:=rev(c(Var7, Var9, Var11, Var13))[corner1pos]]
antData[,frontY:=rev(c(Var6, Var8, Var10, Var12))[corner1pos]]
diagnoseAssumption(antData)

# Looks a bit better....? but not as clear as Var4 and Var5 assumptions.

# Until now, best consistency was seen when we assume Var4 and Var5 are the front.


# Wait. there is a folder called 'afterOrder' ...

read.csv("AntTrackAggregate-order.csv") %>% setDT() -> antData
antData[,centerX:=Var1]
antData[,centerY:=Var2]

antData[,frontX:=Var4]
antData[,frontY:=Var5]
diagnoseAssumption(antData)

# Looks similar to the previous one...
# and, as this file doesn't have order information,
# Maybe we can just see the first coordinate....

antData[,frontX:=Var7]
antData[,frontY:=Var6]
diagnoseAssumption(antData)

# Again chaotic. 
# Let's think about it.... BEEtag reports orientation in
# [0 0 1 0] format, using counterclockwise rotation by 90 degrees.
# Problem is, if the orientation is... for example [1 0 0 0] (no rotation needed)
# Then it means projective transformation of tforminv resulted in the
# upright reading.
# but, it is difficult to say which point will end up as the upper left point
# in projective transformation; thus the incomplete bias 


# check "final" dataset






read.csv("AntTrackAggregateUpdated-1-18-1.csv") %>% setDT() -> aggUpData
read.csv("AntTrackingXYTFID-1-18.csv", header=FALSE) %>% setDT() -> XYFTIDData

nrow(aggUpData)
nrow(XYFTIDData)

aggUpData[,Var3] %>% unique() -> aggUpIDs

aggUpData[,.N,by=Var3] %>% plot()

XYFTIDData[,V5] %>% unique() -> XYFTIDIDs

plot(aggUpIDs)
points(XYFTIDIDs, col="red")

aggUpData[Var3 %in% XYFTIDIDs] %>% nrow()

# so it was not simple filtering














# Let's think about it in this way. If BEETag reported corners in the correct order,
# There is no need of struggling with the order of the corners.
# If BEETag wanted to report it in a random order, it is likely beginning
# from the lowest or highest coordinate on screen and going in a clockwise or counter-clockwise order.

# Are (Var7, Var6) points systematically biased from the center?

antData[,Var7 - Var4] %>% hist() # it is mostly to the left but not all
antData[,Var6 - Var5] %>% hist() # again it is mostly to the left but not all

# I am afraid little can be gained from there. It's not like the first corner is
# always the upper left.





