# run_analysis.R
install.packages("RCurl")
library(RCurl)
 
bin <- getBinaryURL("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
con <- file("FUCI.zip", open = "wb")
writeBin(bin, con)
close(con)
unzip("FUCI.zip", exdir="./data")

 #rbind X_test.txt and X_train.txt
#rbind y_test.txt and y_train.txt

file_list <- list.files("./data/")
X_train = read.table("./data/UCI HAR Dataset/train/X_train.txt", 
                     +                      sep="", 
                     +                      strip.white=TRUE, header=TRUE,  quote = "\"", fill=TRUE)


X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt", 
                                           sep="", 
                                           strip.white=TRUE, header=TRUE,  quote = "\"", fill=TRUE)

names(X_test)
install.packages("plyr")
library(plyr)

#rename the columns
colnames(X_test) <- c(1:561)
colnames(X_train) <- c(1:561)

#rbind the 2 data frames
X_test_train <- rbind(X_test_train<-data.frame(), X_test)
X_test_train <- rbind(X_test_train, X_train)


#read features.txt
#There is no header on the features.txt
feature_labels <- read.table("./data/UCI HAR Dataset/features.txt", 
                             sep="", 
                             strip.white=TRUE, header=FALSE,  quote = "\"", fill=TRUE)

#set the col names for the combined data
colnames(X_test_train) <- feature_labels[,2]

#Do the same for Y_test adn Y_train

Y_train = read.table("./data/UCI HAR Dataset/train/Y_train.txt", 
                                          sep="", 
                                         strip.white=TRUE, header=TRUE,  quote = "\"", fill=TRUE)


Y_test <- read.table("./data/UCI HAR Dataset/test/Y_test.txt", 
                     sep="", 
                     strip.white=TRUE, header=TRUE,  quote = "\"", fill=TRUE)

Y_test_train <- data.frame()
Y_test_train <- rbind(Y_test_train, Y_test)
Y_test_train <- rbind(Y_test_train, Y_train)

#cbind the activity and the X_data

test_train_data <- data.frame()
test_train_data <- cbind(Y_test_train, X_test_train)

#Read the subject
subject_train = read.table("./data/UCI HAR Dataset/train/subject_train.txt", 
                     sep="", 
                     strip.white=TRUE, header=TRUE,  quote = "\"", fill=TRUE)

colnames(subject_train) <- "subject"
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", 
                     sep="", 
                     strip.white=TRUE, header=TRUE,  quote = "\"", fill=TRUE)
colnames(subject_test) <- "subject"

#rbind the test and train subjects.
subject_test_train <- data.frame()
subject_test_train <- rbind(subject_test, subject_train)


#load activity description

activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", 
                     sep="", 
                     strip.white=TRUE, header=FALSE,  quote = "\"", fill=TRUE)


#merge activity_labels with test_train_data
 
test_train_labelled <- merge( activity_labels, test_train_data, by.x="V1", by.y="X5")

colnames(test_train_labelled)[1] <- "Activity_id"

#cbind the subject

test_train_labelled <- cbind(subject_test_train, test_train_labelled)

# doing step 2 now; get only the labels that have mean and std

step2_mean <- grep("mean", colnames(test_train_labelled), value=FALSE)

step2_std <- grep("std", colnames(test_train_labelled), value=FALSE)

#put the mean and std indices together after the activity_id and activity
step2 <- c(1,2,3,step2_mean , step2_std)

#get a subset of the data frame for the columns that have mean and std
x <- test_train_labelled[,step2]


install.packages("dplyr")
library(dplyr)

install.packages("plyr")
library(plyr)

#get the mean by subject and activity for all columns of data

z <- ddply(x,.(subject,Activity), numcolwise(mean) )

#write a txt file to uplaod
write.table(z,file="tidy_data.txt", row.names=FALSE)

