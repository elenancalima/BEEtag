Sys.setlocale("LC_ALL", "English")
#install.packages("rjson")

library(rjson)
library(tidyverse)
library(data.table)

fileName5 <- "ExposureTest_5ms/frameStruct_%05d.json"
fileName6 <- "ExposureTest_6ms/frameStruct_%05d.json"
fileName7 <- "ExposureTest_7ms/frameStruct_%05d.json"
fileName8 <- "ExposureTest_8ms/frameStruct_%05d.json"

loadFrame <- function(frameID, fileName)
{
  json_file <- sprintf(fileName,frameID)
  json_data <- fromJSON(file=json_file)
  json_data
}

loadFrame(1, fileName5)

summaryFrame <- function(frameID, fileName){
  loadFrame(frameID, fileName) -> currentFrame
  
  purrr::map(currentFrame, function(x) x$passCodeActual) -> passCodes
  sum(passCodes==1) -> numReads
  length(currentFrame) -> numSquares
  data.table(frameID,numReads,numSquares)
}

summaryFrame(1, fileName5)

frameCount <- 50

summaryVideo <- function(fileName, frameCount) {
  purrr::map(1:frameCount, ~summaryFrame(.x, fileName)) -> summaryList
  summaryList %>% 
    purrr::reduce(rbind) -> summaryTable
}

summaryVideo(fileName5, frameCount) -> summaryTable5
summaryVideo(fileName6, frameCount) -> summaryTable6
summaryVideo(fileName7, frameCount) -> summaryTable7
summaryVideo(fileName8, frameCount) -> summaryTable8

summaryTable5[,Exposure := 5] -> summaryTable5
summaryTable6[,Exposure := 6] -> summaryTable6
summaryTable7[,Exposure := 7] -> summaryTable7
summaryTable8[,Exposure := 8] -> summaryTable8


rbind(summaryTable5, summaryTable6, summaryTable7, summaryTable8) -> summaryTableAll

summaryTableAll[,propSquares := numSquares/15] -> summaryTableAll
summaryTableAll[,propReads := numReads/numSquares] -> summaryTableAll
summaryTableAll[,finalReads := numReads/15] -> summaryTableAll

lm(finalReads ~ as.factor(Exposure), data = summaryTableAll) -> finalReadsModel
summary(finalReadsModel)

lm(propReads ~ as.factor(Exposure), data = summaryTableAll) -> propReadsModel
summary(propReadsModel)

lm(propSquares ~ as.factor(Exposure), data = summaryTableAll) -> propSquaresModel
summary(propSquaresModel)

library(sjPlot)

plot_model(propSquaresModel, type="pred")
plot_model(finalReadsModel, type="pred")
plot_model(propReadsModel, type="pred")
       