library(dplyr)

## step1. downloading and unzipping dataset

if(!file.exists("./data")){dir.create("./data")}
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile="./data/data.zip",mode="wb")
unzip("./data/data.zip",exdir="./data")

## step2. reading and merging the training and the test sets to create one data set.

## reading training tables:
x_train<-read.table("./data/UCI HAR Dataset/train/x_train.txt")
y_train<-read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt")


## reading test tables:
x_test<-read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt")


#reading features table:
features<-read.table("./data/UCI HAR Dataset/features.txt")

##reading activity lables table:
activityLabels<-read.table("./data/UCI HAR Dataset/activity_labels.txt")

## assinging column names for the tables:

colnames(x_train)<-features[,2]
colnames(y_train)<-"activityid"
colnames(subject_train)<-"subjectid"

colnames(x_test)<-features[,2]
colnames(y_test)<-"activityid"
colnames(subject_test)<-"subjectid"
colnames(activityLabels)<-c("activityid","activitylabel")

##merging all data in one set

data_train<-cbind(subject_train,y_train,x_train)
data_test<-cbind(subject_test,y_test,x_test)
bigdata<-rbind(data_train,data_test)

## step 3 Extracts only the measurements on the mean and standard deviation for each measurement.

## reading column names:

colNames<-colnames(bigdata)

## creating logical vector indexing subjectid, activityid, mean and std

columnindex<-grepl("subjectid|activityid|mean\\(\\)|std\\(\\)",colNames)

## subset the required columns plus subjectid, and activityid in the big dataset

selectedData<-bigdata[,columnindex]

## step 4 Uses descriptive activity names to name the activities in the data set

selectedData$activityid<-activityLabels[selectedData$activityid,2]

## step 5  Appropriately labels the data set with descriptive variable names.

names(selectedData)[2]<-"activity"
names(selectedData)<-gsub("Acc","Accelerometer",names(selectedData))
names(selectedData)<-gsub("Gyro","Gyroscope",names(selectedData))
names(selectedData)<-gsub("^t","Time",names(selectedData))
names(selectedData)<-gsub("Mag","Magnitude",names(selectedData))
names(selectedData)<-gsub("^f","Frequency",names(selectedData))
names(selectedData)<-gsub("BodyBody","Body",names(selectedData))
names(selectedData)<-gsub("tBody","TimeBody",names(selectedData))
names(selectedData)<-gsub("-mean\\(\\)","Mean",names(selectedData))
names(selectedData)<-gsub("-std\\(\\)","STD",names(selectedData))
names(selectedData)<-gsub("angle","Angle",names(selectedData))
names(selectedData)<-gsub("gravity","Gravity",names(selectedData))



## Step 6 From the data set in step 4, creates a second, independent
## tidy data set with the average of each variable for each activity and each subject.

data2<-selectedData %>% 
        group_by(subjectid,activity) %>%
        summarize_all(list(mean=mean))

write.table(data2,"./data/UCI HAR Dataset/seconddata.txt",row.names=F)

