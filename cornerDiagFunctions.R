
diagnoseAssumption <- function(antData, diagData=FALSE) {
  
  # and Var3 must be ID, and Var18 should be time
  
  antData[,ID:=Var3]
  antData[,time:=Var18]
  
  antData %>% pivot_longer(cols=c(centerX, frontX), names_to = "coordType", values_to = "xCor") %>%
    setDT() -> antDataL1
  antDataL1[,.(ID,time,coordType,xCor)] -> antDataL1
  antDataL1[,coordType:=gsub("X", "", coordType)]
  
  antData %>% pivot_longer(cols=c(centerY, frontY), names_to = "coordType", values_to = "yCor") %>%
    setDT() -> antDataL2
  antDataL2[,.(ID,time,coordType,yCor,Var6, Var7, Var8, Var9, Var10, 
               Var11, Var12, Var13, Var14, Var15, Var16, Var17)] -> antDataL2
  antDataL2[,coordType:=gsub("Y", "", coordType)]
  
  antDataL1[antDataL2, on=.(ID, time, coordType)] -> antDataLD
  
  # maybe I can get movement vector from the center movements
  # and see if the center-to-front vector is in the constant relationship with it
  # especially when the speed vector is in reasonable size
  
  antDataLD[,xCorDiff:=xCor - shift(xCor, type="lag"), by=.(ID, coordType)]
  antDataLD[,yCorDiff:=yCor - shift(yCor, type="lag"), by=.(ID, coordType)]
  antDataLD[,timeDiff:=time - shift(time, type="lag"), by=.(ID, coordType)]
  
  antDataLD[timeDiff == 1] -> antDataLDT1
  
  # until now, we made the movement vector
  # and the center-to-front vector is
  
  antDataLDT1 %>% pivot_wider(
    id_cols = c(ID, time, Var6, Var7, Var8, Var9, Var10, 
                Var11, Var12, Var13, Var14, Var15, Var16, Var17),
    names_from = coordType,
    values_from = c(xCorDiff, yCorDiff, xCor, yCor)
  ) %>% setDT() -> antDataLDT1W
  
  #print(antDataLDT1W)
  
  
  
  antDataLDT1W[,centerToFrontX:=xCor_front - xCor_center]
  antDataLDT1W[,centerToFrontY:=yCor_front - yCor_center]
  
  # so, basically, we want polar coordinates of the 
  # movement vectors and the center-to-front vectors
  antDataLDT1W[,centerDiff:=sqrt(xCorDiff_center^2 + yCorDiff_center^2)]
  antDataLDT1W[,centerAngle:=atan2(yCorDiff_center, xCorDiff_center)]
  antDataLDT1W[,centerToFrontDiff:=sqrt(centerToFrontX^2 + centerToFrontY^2)]
  antDataLDT1W[,centerToFrontAngle:=atan2(centerToFrontY, centerToFrontX)]
  
  # and angular difference between center and front is needed,
  # paying attention to the cyclic nature of the angle
  antDataLDT1W[,angleDiff:=centerToFrontAngle - centerAngle]
  antDataLDT1W[angleDiff < -pi, angleDiff:= angleDiff + 2*pi]
  antDataLDT1W[angleDiff > pi, angleDiff:= angleDiff - 2*pi]
  
  antDataLDT1W[ID %in% c(
    3433,   77,   33, 3303,   18, 3360, 3562, 3503, 3268, 3306,
    3471, 3333,  357, 3522)] -> goodData
  goodData[centerDiff > 100] -> goodData
  
  if (diagData == TRUE)
  {
    return (goodData)
  }
  
  antDataLDT1W[ID %in% c(
    3433,   77,   33, 3303,   18, 3360, 3562, 3503, 3268, 3306,
    3471, 3333,  357, 3522)] %>% ggplot(aes(x=centerDiff, y=angleDiff)) +
    geom_point() +
    facet_wrap(~ID)
  
}
