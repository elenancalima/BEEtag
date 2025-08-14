
# If you have an error message about GDAL_DATA being not properly set,
# run
#    SgetGDALconfig("GDAL_DATA")
# and copy the path, and create a Windows environment variable 
# GDAL_DATA containing the path.

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





# Let's first draw 4 rectangular bases. 

# kerfCoef = 1 means the kerf is outside of the polygon 
# (to not remove anything inside the polygon)

# kerfCoef = -1 means the kerf is inside of the polygon
# (to not remove anything outside the polygon)

# kerfCoef = 0 means the kerf follows the line
# (to remove same amount of material inside and outside the polygon)

baseOne <- function(baseUp)
{
  baseOrigin <- c(0, baseUp)
  
  baseVec <- drawRectangle(baseWidth, baseLength, baseOrigin, kerfCoef=1)
  baseVec
}

for (i in 1:8)
{
  baseOne(baseUp=verticalGrid[i]) %>% addTo(partList) -> partList
}



writeDXF(partList, "PolsTest1mm.DXF")

partList <- list()



# and 4 different rectangles for the chamber wall.

wallWidth <- 33
wallLength <- 33

wallOne <- function(wallUp)
{
  wallOrigin <- c(horizontalGrid[2], wallUp)
  wallVec <- drawRectangle(wallWidth, wallLength, wallOrigin, kerfCoef=1)
  wallVec
}

for (i in 1:4)
{
  wallOne(wallUp=verticalGrid[i]) %>% addTo(partList) -> partList
}




# and 4 circles for chambers
chamberEntranceDistance <- 1.5
chamberRight <- wallWidth - chamberEntranceDistance

chamberOne <- function(chamberRadius, chamberUp){
  
  chamberOrigin <- c(chamberRight - chamberRadius, wallLength/2)
  chamberOrigin <- chamberOrigin + c(horizontalGrid[2], chamberUp)
  
  chamberVec <- drawCircle(chamberRadius, chamberOrigin, kerfCoef=-1)
  chamberVec
}

chamberOne(chamberRadius=25.5/2, chamberUp=verticalGrid[1]) %>% addTo(partList) -> partList
chamberOne(chamberRadius=22/2, chamberUp=verticalGrid[2]) %>% addTo(partList) -> partList
chamberOne(chamberRadius=13/2, chamberUp=verticalGrid[3]) %>% addTo(partList) -> partList
chamberOne(chamberRadius=11.5/2, chamberUp=verticalGrid[4]) %>% addTo(partList) -> partList



# And the entrance corridor
corridorWidth <- 1.7  # note that the 'Width' is x-axis and 'Length' is y-axis here. 
corridorLength <- 3 # 'Length' here will determine the 'width of the corridor' for an ant

corridorOne <- function(corridorUp)
{
  corridorOrigin <- c(chamberRight - 0.1, wallLength/2 - corridorLength / 2)
  corridorOrigin <- corridorOrigin + c(horizontalGrid[2], corridorUp)
  
  corridorVec <- drawRectangle(corridorWidth, corridorLength, corridorOrigin, kerfCoef=-1)
  corridorVec
}

for (i in 1:4)
{
  corridorOne(corridorUp=verticalGrid[i]) %>% addTo(partList) -> partList
}



# And the entrance plug; this is a custom shape
plugWidth <- 1.4
plugLength <- corridorLength - 0.1
handleWidth <- 5
handleLength <- 33
combinedPartNum <- 5

plugOrigin <- c(-1 * plugWidth, handleLength / 2 - plugLength / 2)

combinedOrigin <- c(horizontalGrid[3],0)

plugVec <- drawRectangle(plugWidth, plugLength, plugOrigin, kerfCoef=1)
handleVec <- drawRectangle(handleWidth, handleLength, c(0,0), kerfCoef=-1)

combinedVec <- rbind(plugVec, handleVec)

# custom shape: skip and reorder points
plotCutting(combinedVec)
combinedVec[c(1,2,6,7,8,9,3,4,1),] -> combinedVec
plotCutting(combinedVec)

translateVecData(combinedVec, combinedOrigin) -> combinedVec

combinedVec %>% addTo(partList) -> partList

combinedVec %>% translateVecData(c(0, verticalGrid[2])) %>% addTo(partList) -> partList
combinedVec %>% translateVecData(c(0, verticalGrid[3])) %>% addTo(partList) -> partList
combinedVec %>% translateVecData(c(0, verticalGrid[4])) %>% addTo(partList) -> partList


writeDXF(partList, "PolsTest3mm.DXF")




#### Tag cutter design

partList <- list()

totalWidth <- 20.5
totalHeight <- 17.5
bladeWidth <- 10.1

drawRectangle(totalWidth, totalHeight, c(0,0), kerfCoef=1) -> boundaryVec
drawRectangle(bladeWidth, totalHeight, c(0,0), kerfCoef=1) -> leftBladeVec
drawRectangle(bladeWidth, totalHeight, c(totalWidth - bladeWidth, 0), kerfCoef=1) -> rightBladeVec

combinedVec <- rbind(boundaryVec, leftBladeVec, rightBladeVec)
plotCutting(combinedVec)

# custom shape...

combinedVec[c(1,7,3,14,1),] -> combinedVec
plotCutting(combinedVec)

combinedVec %>% addTo(partList) -> partList

# holding column
holdingOrigin <- c(-10,5)
drawRectangle(50, 19, holdingOrigin, kerfCoef=1) -> holdingVec
holdingVec %>% addTo(partList) -> partList

# screw holes
drawCircle(2.6, c(-2, 14), kerfCoef=1) -> screwHoleVec1
drawCircle(2.6, c(28, 14), kerfCoef=1) -> screwHoleVec2

screwHoleVec1 %>% addTo(partList) -> partList
screwHoleVec2 %>% addTo(partList) -> partList

plotPartList(partList)

writeDXF(partList, "cutter1mm.DXF")

# cover
partList <- list()
holdingVec %>% translateVecData(c(0, 25)) %>% addTo(partList) -> partList
screwHoleVec1 %>% translateVecData(c(0, 25)) %>% addTo(partList) -> partList
screwHoleVec2 %>% translateVecData(c(0, 25)) %>% addTo(partList) -> partList

plotPartList(partList)

writeDXF(partList, "cutter3mm.DXF")


# and the backbone
partList <- list()
screwHoleVec1 %>% addTo(partList) -> partList
screwHoleVec2 %>% addTo(partList) -> partList

drawRectangle(70, 19, holdingOrigin, kerfCoef=1) -> backboneVec

backboneVec %>% translateVecData(c(-15,0)) %>% addTo(partList) -> partList

plotPartList(partList)

writeDXF(partList, "cutter5mm.DXF")





# kerfCoef = 1 means the kerf is outside of the polygon 
# (to not remove anything inside the polygon)

# kerfCoef = -1 means the kerf is inside of the polygon
# (to not remove anything outside the polygon)

# kerfCoef = 0 means the kerf follows the line
# (to remove same amount of material inside and outside the polygon)

source("laserCuttingFunctions.R")
partList <- list()

drawRectangle(20,10,c(0,0),1) -> rect1
drawRectangle(30,10,c(0,10),1) -> rect2

rbind(rect1, rect2) -> combinedVec
plotCutting(combinedVec)
combinedVec[c(5,9,8,7,3,2,5),] -> newVec
plotCutting(newVec)

drawCircle(2.5, c(10,5),-1) -> hole1


#rect1 %>% addTo(partList) -> partList
#rect2 %>% addTo(partList) -> partList
newVec %>% addTo(partList) -> partList
hole1 %>% addTo(partList) -> partList

plotPartList(partList)



### diffuser designs

partList <- list()

# outer stand
drawRectangle(27,15,c(0,0),1) -> outer
drawRectangle(17,3,c(5,-3),-1) -> basePlug

rbind(outer, basePlug) -> combinedOuter

plotCutting(combinedOuter)

combinedOuter[c(5,4,3,2,8,7,10,9,5),] -> combinedOuter
plotCutting(combinedOuter)

combinedOuter %>% addTo(partList) -> partList


#stand hole
drawRectangle(23,11,c(2,2),1) -> hole
hole %>% addTo(partList) -> partList


plotPartList(partList)


# base
drawRectangle(23,23,c(2,-30),1) -> base

# base hole
drawRectangle(17,3, c(5,-30-kerf),-1) -> baseHole

rbind(base, baseHole) -> combinedBase
plotCutting(combinedBase)

combinedBase[c(5,4,3,2,7,8,9,10,5),] -> combinedBase
plotCutting(combinedBase)

combinedBase %>% addTo(partList) -> partList

plotPartList(partList)

writeDXF(partList, "diffuserStand3mm.DXF")




##### diffuser cover

partList <- list()

# outer
drawRectangle(81,81,c(0,0),1) -> outer

# hole
drawCircle(15.1,c(40.5,40.5),-1) -> hole

outer %>% addTo(partList) -> partList
hole %>% addTo(partList) -> partList
plotPartList(partList)

writeDXF(partList, "diffuserCover3mm.DXF")
