library(reshape2)
filename <- "assignment_dataset.zip"
## Download and unzip the dataset:
if (!file.exists(filename)){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(url, filename, method="curl")
}  
if (!file.exists("UCI_HAR_Dataset")) { 
  unzip(filename) 
}

# Load activity labels + features
activityLabels <- read.table("UCI_HAR_Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI_HAR_Dataset/features.txt")
features[,2] <- as.character(features[,2])
# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)
# Load the datasets
train <- read.table("UCI_HAR_Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI_HAR_Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI_HAR_Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)
###########
test <- read.table("UCI_HAR_Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI_HAR_Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI_HAR_Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels to columns
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)
#melt and cast the mean
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)
#allData.sd <- dcast(allData.melted, subject + activity ~ variable, sd)

#write the tidy dataset
write.csv(allData.mean, "tidyDataMean.csv", row.names = FALSE, quote = FALSE)
#write.csv(allData.mean, "tidyDataSd.csv", row.names = FALSE, quote = FALSE)