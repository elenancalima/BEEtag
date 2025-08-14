

Sys.setlocale("LC_ALL", "English")
library(tidyverse)
library(data.table)

source("laserCuttingFunctions.R")


kerf <- 0.2
spacing <- 7
baseLength <- 33
baseWidth <- 33

0:30 * (spacing + baseLength) -> verticalGrid
0:30 * (spacing + baseWidth) -> horizontalGrid

partList <- list()


baseOrigin <- c(0, 0)

baseVec <- drawRectangle(baseWidth, baseLength, baseOrigin, kerfCoef=1)
baseVec

baseVec %>% addTo(partList) -> partList

plotPartList(partList)

wallWidth <- 33
wallLength <- 33

chamberEntranceDistance <- 5.5
chamberRight <- wallWidth - chamberEntranceDistance

chamberOne <- function(chamberRadius, chamberUp){
  
  chamberOrigin <- c(chamberRight - chamberRadius, wallLength/2)
  chamberOrigin <- chamberOrigin + c(horizontalGrid[1], chamberUp)
  
  chamberVec <- drawCircle(chamberRadius, chamberOrigin, kerfCoef=-1)
  chamberVec
}

chamberOne(chamberRadius=25.5/2, chamberUp=verticalGrid[1]) %>% addTo(partList) -> partList


# And the entrance corridor
corridorWidth <- 5.7  # note that the 'Width' is x-axis and 'Length' is y-axis here. 
corridorLength <- 3 # 'Length' here will determine the 'width of the corridor' for an ant

corridorOne <- function(corridorUp)
{
  corridorOrigin <- c(chamberRight - 0.1, wallLength/2 - corridorLength / 2)
  corridorOrigin <- corridorOrigin + c(horizontalGrid[1], corridorUp)
  
  corridorVec <- drawRectangle(corridorWidth, corridorLength, corridorOrigin, kerfCoef=-1)
  corridorVec
}

corridorOne(corridorUp=verticalGrid[1]) %>% addTo(partList) -> partList


plotPartList(partList) 


# Now, the feeder slider slot

feederSlotWidth <- 1.1
feederSlotLength <- 17
feederSlotOrigin <- c(chamberRight - 0.1 + 3, wallLength/2 - feederSlotLength / 2)

feederSlotVec <- drawRectangle(feederSlotWidth, feederSlotLength, feederSlotOrigin, kerfCoef=-1)
feederSlotVec %>% addTo(partList) -> partList


# and the rubber band slot
rubberBandSlotWidth <- 1.1
rubberBandSlotLength <- 1.1

rbSlot1 <- drawRectangle(rubberBandSlotWidth, rubberBandSlotLength, c(0,2.5), kerfCoef=1)
rbSlot2 <- drawRectangle(rubberBandSlotWidth, rubberBandSlotLength, c(baseWidth - rubberBandSlotWidth,2.5), kerfCoef=1)
rbSlot3 <- drawRectangle(rubberBandSlotWidth, rubberBandSlotLength, c(baseWidth - rubberBandSlotWidth,baseLength-2.5-rubberBandSlotLength), kerfCoef=1)
rbSlot4 <- drawRectangle(rubberBandSlotWidth, rubberBandSlotLength, c(0,baseLength-2.5-rubberBandSlotLength), kerfCoef=1)

rbSlot1 %>% addTo(partList) -> partList
rbSlot2 %>% addTo(partList) -> partList
rbSlot3 %>% addTo(partList) -> partList
rbSlot4 %>% addTo(partList) -> partList

plotPartList(partList) + ylim(-1,44) + xlim(-1,44)

writeDXF(partList, "ChamberWallWithSlot1[8inchX30copies.dxf")


# Small chamber

partList <- list()
baseVec %>% addTo(partList) -> partList
chamberOne(chamberRadius=11.5/2, chamberUp=verticalGrid[1]) %>% addTo(partList) -> partList
corridorOne(corridorUp=verticalGrid[1]) %>% addTo(partList) -> partList
feederSlotVec %>% addTo(partList) -> partList

rbSlot1 %>% addTo(partList) -> partList
rbSlot2 %>% addTo(partList) -> partList
rbSlot3 %>% addTo(partList) -> partList
rbSlot4 %>% addTo(partList) -> partList

plotPartList(partList) + ylim(-1,44) + xlim(-1,44)


writeDXF(partList, "smallChamber1[8inchX5copies.dxf")




partList <- list()

# And the feeder slider itself
feederSliderWidth <- 5
feederSliderLength <- 13

feederSliderOrigin <- c(0,(baseLength - feederSlotLength) / 2 + feederSlotLength - feederSliderLength)

feederSliderVec <- drawRectangle(feederSliderWidth, feederSliderLength, feederSliderOrigin, kerfCoef=-1)

feederSliderVec %>% addTo(partList) -> partList


topSlot <- drawRectangle(1.925,11, feederSliderOrigin, kerfCoef=-1)
topSlot %>% addTo(partList) -> partList

doorSlot <- drawRectangle(2.3,3, feederSliderOrigin+c(1.825,3), kerfCoef=-1)
doorSlot %>% addTo(partList) -> partList

plotPartList(partList) + ylim(-1,44) + xlim(-1,44)


writeDXF(partList, "doorSlide1[16inchX3copies.dxf")

# and the cover with a slot

partList <- list()
coverWidth <- 33
coverLength <- 33
coverOrigin <- c(0,0)

coverVec <- drawRectangle(coverWidth, coverLength, coverOrigin, kerfCoef=1)
coverVec %>% addTo(partList) -> partList

coverSlotWidth <- 1.1
coverSlotLength <- 6.1
coverSlotOrigin <- c(chamberRight - 0.1 + 3, coverLength/2 + feederSlotLength/2 - coverSlotLength)

coverSlotVec <- drawRectangle(coverSlotWidth, coverSlotLength, coverSlotOrigin, kerfCoef=-1)
coverSlotVec %>% addTo(partList) -> partList


rbSlot1 %>% addTo(partList) -> partList
rbSlot2 %>% addTo(partList) -> partList
rbSlot3 %>% addTo(partList) -> partList
rbSlot4 %>% addTo(partList) -> partList


plotPartList(partList) + ylim(-1,44) + xlim(-1,44)



writeDXF(partList, "coverWithSlot1[16inchX60copies.dxf")


# And the base holder

partList <- list()

drawRectangle(43, 43, c(0,0), kerfCoef=1) %>% addTo(partList) -> partList
drawRectangle(baseWidth, baseLength, c(5,0), kerfCoef=1) %>% addTo(partList) -> partList


plotPartList(partList) + ylim(-1,44) + xlim(-1,44)

writeDXF(partList, "baseHolder1[8inchX3copies.dxf")


# And the actual feeder

partList <- list()

feederWidth <- 6
feederLength <- 17

feederOrigin <- c(baseWidth,baseLength / 2 - feederLength / 2)

feederVec <- drawRectangle(feederWidth, feederLength, feederOrigin, kerfCoef=1)

feederVec %>% addTo(partList) -> partList


plotPartList(partList) + ylim(-1,44) + xlim(-1,44)

writeDXF(partList, "feederBottom1[16inchX5copies.dxf")

carveSide1 <- drawRectangle(1.4, feederLength / 2 - corridorLength / 2, feederOrigin + c(0, 0), kerfCoef=0)
carveSide2 <- drawRectangle(1.4, feederLength / 2 - corridorLength / 2, feederOrigin + c(0, feederLength / 2 + corridorLength / 2), kerfCoef=0)
carveSide1 %>% addTo(partList) -> partList
carveSide2 %>% addTo(partList) -> partList



slotSize <- 0.4
slotLength <- 2.6
feedingSlot <- drawRectangle(slotLength, slotSize, feederOrigin + c(-0.2, feederLength / 2 - slotSize / 2), kerfCoef=-1)
feedingSlot %>% addTo(partList) -> partList

bowlSize <- 10
bowl <- drawRectangle(2.5, bowlSize, feederOrigin + c(slotLength - 0.4, feederLength /2 - bowlSize /2), kerfCoef=-1)
bowl %>% addTo(partList) -> partList
plotPartList(partList) + ylim(-1,44) + xlim(-1,44)

writeDXF(partList, "feeder1[8inchX5copies.dxf")
