library(terra)

drawRectangle <- function(baseWidth, baseLength, baseOrigin, kerfCoef) {
  #kerfCoef 1: out, 0: middle, -1: in.
  newWidth <- baseWidth + kerf * kerfCoef
  newLength <- baseLength + kerf * kerfCoef
  
  x <- c(0, newWidth, newWidth, 0, 0)
  y <- c(0, 0, newLength, newLength, 0)
  x <- x + baseOrigin[1] - kerf / 2 * kerfCoef
  y <- y + baseOrigin[2] - kerf / 2 * kerfCoef
  
  vecData <- cbind(x, y)
  vecData
}

generateCirclePoints <- function(center_x, center_y, radius, resolution = 100) {
  # Create a sequence of angles from 0 to 2*pi
  angles <- seq(0, 2 * pi, length.out = resolution + 1)
  
  # Calculate x and y coordinates
  x <- center_x + radius * cos(angles)
  y <- center_y + radius * sin(angles)
  
  cbind(x = x, y = y)
}

drawCircle <- function(radius, origin, kerfCoef) {
  generateCirclePoints(origin[1], origin[2], radius + kerf /2 * kerfCoef, resolution=360)
}


translateVecData <- function(vecData, origin) {
  t(vecData) + origin -> resultData
  t(resultData)
}

compileParts <- function(vecList) {
  length(vecList) -> n
  map2(1:n, vecList, ~cbind(id=.x, part=.x, .y)) -> listWithID
  listWithID %>% do.call(what=rbind) -> vecData
  vecData
}

addTo <- function(vecData, partList) {
  partList[[length(partList) + 1]] <- vecData
  partList
}

plotCutting <- function(combinedVec){
  plot(combinedVec,type="l")
  text(combinedVec,labels=1:nrow(combinedVec))
}


writeDXF <- function(partList, filename){
  compileParts(partList) -> vecData
  pols <- terra::vect(vecData, type="lines", crs="local")
  #pols
  writeVector(pols, filename, filetype = "DXF", overwrite = TRUE)
  print(vect("PolsTest.DXF"))
}