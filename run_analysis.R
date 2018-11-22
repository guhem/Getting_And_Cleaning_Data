rm(list=ls())
setwd("~/Coursera/Getting_And_Cleaning_Data/")

library(dplyr)

#Get Data

zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"

if (!file.exists(zipFile)) {
  download.file(zipUrl, zipFile, mode = "wb")}


dataPath <- "UCI HAR Dataset"
if (!file.exists(dataPath)) {
  unzip(zipFile)
}

#read data
trainingSubjects <- read.table(file.path(dataPath, "train", "subject_train.txt"))
trainingValues <- read.table(file.path(dataPath, "train", "X_train.txt"))
trainingActivity <- read.table(file.path(dataPath, "train", "y_train.txt"))

testSubjects <- read.table(file.path(dataPath, "test", "subject_test.txt"))
testValues <- read.table(file.path(dataPath, "test", "X_test.txt"))
testActivity <- read.table(file.path(dataPath, "test", "y_test.txt"))

features <- read.table(file.path(dataPath, "features.txt"), as.is = TRUE)

activities <- read.table(file.path(dataPath, "activity_labels.txt"))
colnames(activities) <- c("activityId", "activityLabel")

#merge data
test <- cbind(testSubjects, testValues, testActivity)
training <- cbind(trainingSubjects, trainingValues, trainingActivity)

dataset <- rbind(test,training)
colnames(dataset) <- c("subject", features[,2], "activity")

#coulmns to keep
mean_sd  <- grepl("mean|std|subject|activity", colnames(dataset))
dataset <- dataset[,mean_sd]

#name activities in dataset
dataset$activity <- factor(dataset$activity, levels = activities[, 1], labels = activities[, 2])

#name variables
ColNames <- colnames(dataset)
ColNames <- gsub("^f", "FrequencyDomain", ColNames)
ColNames <- gsub("^t", "TimeDomain", ColNames)
ColNames <- gsub("Acc", "Accelerometer", ColNames)
ColNames <- gsub("Gyro", "Gyroscope", ColNames)
ColNames <- gsub("Mag", "Magnitude", ColNames)
ColNames <- gsub("Freq", "Frequency", ColNames)
ColNames <- gsub("mean", "Mean", ColNames)
ColNames <- gsub("std", "StandardDeviation", ColNames)
ColNames <- gsub("BodyBody", "Body", ColNames)

ColNames <- gsub("-","", ColNames)
ColNames <- gsub("[\\(\\)]", "", ColNames)

colnames(dataset) <- ColNames

write.table(dataset, file="tidy_dataset.txt", quote = FALSE, sep="\t", row.names = FALSE)

#New dataset with average of each variable ofr each activity and each subject
dataset2 <- aggregate(. ~subject + activity, dataset, mean)
dataset2 <- dataset2[order(dataset2$subject,dataset2$activity),]
write.table(dataset2, file = "tidy_dataset2.txt", quote = FALSE, sep="\t", row.names = FALSE)


