Sys.setlocale("LC_ALL", "English")

#install.packages("xml2")
library(xml2)
library(tidyverse)
library(data.table)

loadID <- function(sID)
{
  xml_data <- read_xml(sprintf("structTest_%03d.xml",sID))
  xmlExtract <- function(xml_data, varName) {
    xml_find_all(xml_data, varName) %>%
      xml_text() %>%
      trimws() %>% 
      as.numeric()
  }
  
  xml_data %>% xmlExtract("//CentroidX") -> cx
  xml_data %>% xmlExtract("//CentroidY") -> cy
  xml_data %>% xmlExtract("//number") -> nb
  
  data.table(nb=rep(0,900)) -> xmTable
  xmTable$nb[1:length(nb)] <- nb
  colnames(xmTable) <- c(as.character(unique(nb[nb > 0])))
  xmTable
}

loadID(1)

1:6 %>% purrr::map(loadID) -> listXML
#cbind list
listXML %>% 
  purrr::reduce(cbind) -> xmTableFinal

xmTableFinal[xmTableFinal > 0] <- 1
xmTableFinal[,time:=1:nrow(xmTableFinal)]

xmTableFinal %>% pivot_longer(cols=1:6, names_to = "ID", values_to = "value") ->
  xmTableFinalLong

xmTableFinalLong %>% 
  ggplot(aes(x=time,y=as.factor(ID))) + geom_tile(aes(fill=value))

xmTableFinalLong %>% setDT()
xmTableFinalLong[value > 0]
xmTableFinalLong[!(ID %in% c(9557, 9170, 8016, 6893, 13235, 12740)) & value > 0]




















xml_find_all(xml_data, "//CentroidX") %>%
  xml_text() %>%
  trimws() %>%
  as.numeric() -> cx

as.numeric() -> cx
cx <- 
  cy <- xml_find_all(xml_data, "//CentroidY")
nb <- xml_find_all(xml_data, "//number")
vals <- trimws(xml_text(recs))

#labs <- trimws(xml_attr(recs, "label"))

cols <- xml_attr(xml_find_all(xml_data, "//CentroidX"), "name")


xml_attr(xml_data, "CentroidX")
