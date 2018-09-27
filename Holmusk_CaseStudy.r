## import the packages ##
library(dplyr)

## set working directory ##
setwd("C:/Kavitha/SMU")

## import the files ##

bill_amount <- read.csv("bill_amount.csv")
bill_id <- read.csv("bill_id.csv")
clinical_data <- read.csv("clinical_data.csv")
demographics <- read.csv("demographics.csv")

clinical_data$bmi <- clinical_data$weight/((clinical_data$height)/100)^2 #derived variable bmi

clinical_data <- clinical_data %>% group_by(id) %>%
  mutate(visit_no = rank(date_of_admission, ties.method = "first")) #derived variable visit number

## Join bill_id and bill_amount to obtain the bill amount ##

bill_amount_DOA_level <- left_join(bill_id,bill_amount,by=c("bill_id"))

bill_amount_DOA_level <-bill_amount_DOA_level %>% group_by(patient_id, date_of_admission) %>% summarise(total_amount =
                                                                                                                        sum(amount),
                                                                                                                        bill_cnt = sum(!is.na(bill_id)))
## Join bill amount with clinical data ##
clinical_data_master <- left_join(clinical_data,bill_amount_DOA_level,by = c("id"="patient_id","date_of_admission" = "date_of_admission"))

patient_master <- left_join(clinical_data_master,demographics,by=c("id"="patient_id"))

##Export the final file ##
write.csv(patient_master,"patient_master.csv",row.names = F)

##Number of symptoms

patient_master$symptom_cnt = patient_master$symptom_1+patient_master$symptom_2+patient_master$symptom_3+patient_master$symptom_4+patient_master$symptom_5

