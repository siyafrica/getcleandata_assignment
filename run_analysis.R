#load the reshape2 library
library("reshape2")

#comment Ensuring the data path exists...
dataPath <- "./data"
if (!file.exists(dataPath)) { dir.create(dataPath) }
#comment Checking if the data set archive was already downloaded
fileName <- "Dataset.zip"
filePath <- paste(dataPath,fileName,sep="/")
if (!file.exists(filePath)) {
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        message("Downloading the data set archive...")
        download.file(url=fileURL,destfile=filePath,method="curl")
}
#comment Timestamping the data set archive file with when it wad downloaded.
fileConn <- file(paste(filePath,".timestamp",sep=""))
writeLines(date(), fileConn)
close(fileConn)
#comment Extracting the data set files from the archive.
unzip(zipfile=filePath, exdir=dataPath)
# Set the data path of the extracted archive files...
dataSetPath <- paste(dataSetPath,"UCI HAR Dataset",sep="/")
#comment Reading training & test column files into respective x,y,s variables.
xTrain <- read.table(file=paste("UCI HAR Dataset","/train/","X_train.txt",sep=""),header=FALSE)
xTest <- read.table(file=paste("UCI HAR Dataset","/test/","X_test.txt",sep=""),header=FALSE)
yTrain <- read.table(file=paste("UCI HAR Dataset","/train/","y_train.txt",sep=""),header=FALSE)
yTest <- read.table(file=paste("UCI HAR Dataset","/test/","y_test.txt",sep=""),header=FALSE)
sTrain <- read.table(file=paste("UCI HAR Dataset","/train/","subject_train.txt",sep=""),header=FALSE)
sTest <- read.table(file=paste("UCI HAR Dataset","/test/","subject_test.txt",sep=""),header=FALSE)

#comment Readng feaure names and sets column/variable names respectively
features <- read.table(file=paste("UCI HAR Dataset","features.txt",sep="/"),header=FALSE)
names(xTrain) <- features[,2]
names(xTest) <- features[,2]
names(yTrain) <- "Class_Label"
names(yTest) <- "Class_Label"
names(sTest) <- "SubjectID"
names(sTrain) <- "SubjectID"

#comment Merging (appending) the training and test data set rows.
xData <- rbind(xTrain, xTest)
yData <- rbind(yTrain, yTest)
sData <- rbind(sTrain, sTest)

#comment Creating a unified data set (data frame).
data <- cbind(xData, yData, sData)

#comment Extracting measurements on mean & standard deviation, for each measurement.
matchingCols <- grep("mean|std|Class|Subject", names(data))
data <- data[,matchingCols]

#comment Using descriptive activity names to name the activities in data set.eg. activity names on the class labels
# NOTE: I got the Class_Label idea from a post on the discussion groups.
activityNames <- read.table(file=paste("UCI HAR Dataset","activity_labels.txt",sep="/"),header=FALSE)
names(activityNames) <- c("Class_Label", "Class_Name")
data <- merge(x=data, y=activityNames, by.x="Class_Label", by.y="Class_Label" )

#comment Labeling data with descriptive variable names by removing special characters in the column names.
names(data) <- gsub(pattern="[()]", replacement="", names(data))

#comment and by replacing hyphen's with underscores in the column names
names(data) <- gsub(pattern="[-]", replacement="_", names(data))

#comment Removing columns used only for tidying up the data set.
data <- data[,!(names(data) %in% c("Class_Label"))]

#comment Melting the data set, note this is why we require reshape2 library.
meltdataset <- melt(data=data, id=c("SubjectID", "Class_Name"))

#comment Creating a second, independent, tidy data set which contains the average of each variable for each activity and subject.
tidyData <- dcast(data=meltdataset, SubjectID + Class_Name ~ variable, mean)

#comment Saving the tidy data set to file.
tidyFilePath <- paste(dataPath,"TidyDataSet.txt",sep="/")
write.csv(tidyData, file=tidyFilePath, row.names=FALSE)