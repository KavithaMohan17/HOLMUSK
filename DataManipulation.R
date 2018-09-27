setwd("C:/Users/kavmohan/Desktop/Operating cost/Analysis dashboard/R codes/September/IN Import/")
library(XML)
library(xml2)
library(data.table)
library(reshape2)
library(dplyr)
library(tidyr)
library(readr)
library(readxl)


file.list <- list.files(pattern='*.xlsx')

### Read the file ###
for( j in 1: length(file.list))
{
export <- read_excel(file.list[j])  
colnames(export)[colnames(export)=="TO_CHAR(TRANS_DATE,'DD/MM/YYHH24:MI:SS')"] <- "TRANS_DATE"
colnames(export)[colnames(export)=="TO_CHAR(IMAGE)"] <- "IMAGE"
export <- export[which(export$TRANS_TYPE == "U"),]
export_subset <- export[c("USER_ID","SUB_AREA","GENERIC_2","GENERIC_3","IMAGE","GENERIC_1","TRANS_DATE")]
colnames(export_subset)[colnames(export_subset)=="GENERIC_2"] <- "HAWB"
colnames(export_subset)[colnames(export_subset)=="GENERIC_3"] <- "ORIGIN"
colnames(export_subset)[colnames(export_subset)=="GENERIC_1"] <- "DESTN"
export_subset$Type = "export"
export_subset$IMAGE = iconv(export_subset$IMAGE, "latin1", "ASCII//TRANSLIT")

# Read XML

for(i in 1:nrow(export_subset))
{
  

  tagsXML <- xmlParse(export_subset$IMAGE[i])
  
  # Convert to List
  tagsList <- xmlToList(tagsXML)
  
  # Each List element is a character vector.  Convert each of these into a data.table
  tagsList <- lapply(tagsList, function(x) as.data.table(as.list(x)))
  
  # Rbind all the 1-row data.tables into a single data.table
  tags <- rbindlist(tagsList, use.names = T, fill = T)
  tags <- tags[is.na(tags$name) == T,]
  tags$name <- NULL
  new_data <- export_subset[i,]
  new_data$IMAGE=NULL

  changes <- crossing(new_data,tags)
  colnames(changes)[colnames(changes)==".attrs"] <- "Field_Changed"
  
  if(i==1)
  {
    changes_log = changes
  } else {
    changes_log = rbind(changes_log,changes)
  }
}
eval(parse(text = paste("export",j, "<- changes_log", sep = '')))
rm(changes_log)
rm(changes)
}

export_data_total = rbind(export1,export2,export3,export4,export5,export6,export7,export8)
export_data_total$Type = "Import"

write.csv(export_data_total,"Malaysia_Import.csv",row.names = F)
write.csv(export_data_total_subset,"India_Import_only_changes.csv",row.names = F)

export_data_total_subset <- India_Import_only_changes[which(toupper(India_Import_only_changes$before) != toupper(India_Import_only_changes$after)),]

##Imports parsing the data## 
setwd("C:/Users/kavmohan/Desktop/Operating cost/Analysis dashboard/R codes/July/Import data/")

file.list <- list.files(pattern='*.xlsx')

### Read the file ###
for( j in 1: length(file.list))
{
  import <- read_excel(file.list[j])  
  import_subset <- import[c("USER_ID","SUB_AREA","GENERIC_2","GENERIC_3","IMAGE","GENERIC_1","TRANS_DATE")]
  colnames(import_subset)[colnames(import_subset)=="GENERIC_2"] <- "HAWB"
  colnames(import_subset)[colnames(import_subset)=="GENERIC_3"] <- "ORIGIN"
  colnames(import_subset)[colnames(import_subset)=="GENERIC_1"] <- "DESTN"
  import_subset$Type = "import"
  import_subset$IMAGE = iconv(import_subset$IMAGE, "latin1", "ASCII//TRANSLIT")
  
  
  
  # Read XML
  
  for(i in 1:nrow(import_subset))
  {
    
    
    tagsXML <- xmlParse(import_subset$IMAGE[i])
    
    # Convert to List
    tagsList <- xmlToList(tagsXML)
    
    # Each List element is a character vector.  Convert each of these into a data.table
    tagsList <- lapply(tagsList, function(x) as.data.table(as.list(x)))
    
    # Rbind all the 1-row data.tables into a single data.table
    tags <- rbindlist(tagsList, use.names = T, fill = T)
    tags <- tags[is.na(tags$name) == T,]
    tags$name <- NULL
    new_data <- import_subset[i,]
    new_data$IMAGE=NULL
    
    changes <- crossing(new_data,tags)
    colnames(changes)[colnames(changes)==".attrs"] <- "Field_Changed"
    
    if(i==1)
    {
      changes_log = changes
    } else {
      changes_log = rbind(changes_log,changes)
    }
  }
  eval(parse(text = paste("import",j, "<- changes_log", sep = '')))
  rm(changes_log)
  rm(changes)
}

import_data_total = rbind(import1,import2,import3,import4,import5,import6,import7)

write.csv(import_data_total,"import_july_th_sg.csv",row.names = F)

### EFR data ###
setwd("C:/Users/kavmohan/Desktop/Operating cost/Analysis dashboard/R codes/July/EFR/")
file.list <- list.files(pattern='*.csv')

for(i in 1:length(file.list))
{
  eval(parse(text = paste("EFR",i, "<- read.csv(file.list[i])", sep = '')))
  
}

EFR_combine = rbind(EFR1,EFR2)
write.csv(EFR_combine,"EFR_july_th_sg.csv",row.names = F)
