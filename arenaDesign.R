
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
baseWidth <- 38

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

for (i in 1:4)
{
  baseOne(baseUp=verticalGrid[i]) %>% addTo(partList) -> partList
}


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

chamberOne <- function(chamberRadius, chamberUp){
  chamberRight <- wallWidth - chamberEntranceDistance
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
corridorLength <- 1.2 # 'Length' here will determine the 'width of the corridor' for an ant

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
plugLength <- 1.1
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



writeDXF(partList, "PolsTest.DXF")
