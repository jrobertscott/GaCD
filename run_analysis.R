library(plyr)
library(dplyr)

features_data <- read.table("./UCI HAR Dataset/features.txt")
subject_test_data <- read.table("./UCI HAR Dataset/test/subject_test.txt")
x_test_data <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test_data <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_train_data <- read.table("./UCI HAR Dataset/train/subject_train.txt")
x_train_data <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train_data <- read.table("./UCI HAR Dataset/train/y_train.txt")

renamed_y_test <- rename(y_test_data, activity = V1) #since x has V1
renamed_y_train <- rename(y_train_data, activity = V1)
renamed_y_subject_test <- rename(subject_test_data, patient_ID = V1)
renamed_y_subject_train <- rename(subject_train_data, patient_ID = V1)
subject_y_test <- bind_cols(renamed_y_subject_test, renamed_y_test) #includes patient ID
subject_y_train <- bind_cols(renamed_y_subject_train, renamed_y_train)
test_data <- bind_cols(subject_y_test, x_test_data) #merges test, now 563 vars
train_data <- bind_cols(subject_y_train, x_train_data)
full_data <- bind_rows(test_data, train_data) #merges test and train
ord_full <- arrange(full_data, patient_ID) #orders by patient
data <- ord_full #copy of data
names(data)[3:563] <- as.character(features_data$V2) #rename 561 vars (element 3:563 of row1) with 
data <- data[!duplicated(names(data))] #remove duplicated
extracted <- select(data, patient_ID, activity, contains("mean"), contains("std")) #extracts mean and std
extracted$activity <- as.factor(extracted$activity)
extracted$activity <- revalue(extracted$activity, c("1"="WALKING", "2" = "WALKING_UPSTAIRS", "3" = "WALKING_DOWNSTAIRS", "4" = "SITTING", "5"="STANDING", "6"="LAYING"))
pre_tidy <- group_by(extracted, patient_ID, activity)
tidy <- summarise_each(pre_tidy, funs(mean))
write.csv(tidy, file = "tidy.csv")
write.table(tidy, file = "tidy.txt", row.names = FALSE)
