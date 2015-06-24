# Starting the function
## Folder Structure
⋅⋅* The function run_analysis should be sourced to the workspace
⋅⋅* The function does not download the dataset required since it's assumed most people peer-reviewing already have it downloaded
1. The dataset is looked in two different directories "Dataset" and the original "UCI HAR Dataset"
2. A couple of message and warnings about the configuration of the folder structure might give a hint to configuring the workspace correctly (Sorry for the inconvenience, might use file.download next time)
3. Once the data is found (or the folder that is) the path to the files and file listing is configured

## Merging the data
1. Each file is stored as individual functions
⋅⋅1. xTrain: X_train.txt
⋅⋅2. yTrain: y_Train.txt
⋅⋅3. subTrain: subject_train.txt
⋅⋅4. yTest: y_test.txt
⋅⋅5. xTest: X_test.txt
⋅⋅6. subTest: subject_test.txt
⋅⋅7. activity: activity_labels.txt, obtained by quering the root files with "activity_labels as string"
⋅⋅8. features: features.txt

2. The names of all variables are set as:
⋅⋅* namesList<-features$V2;
⋅⋅* names(xTest)<-namesList;
⋅⋅* names(xTrain)<-namesList;
⋅⋅* names(yTest)<-"Activity";
⋅⋅* names(yTrain)<-"Activity";
⋅⋅* names(subTrain)<-"Subject";
⋅⋅* names(subTest)<-"Subject";
        
3. Join the columns of test files and train files, then add both as rows.
```
		XYTest<-cbind(yTest,subTest,xTest)
        XYTrain<-cbind(yTrain,subTrain,xTrain)
        XYAll<-rbind(XYTrain,XYTest)
```

## Extraction of important data
1. As only the columns containing mean and STD values are of importance, I obtain a numerical vector of the element numbers in "Features" that contain Mean or STD
..1.	```
		asMean<-grep("mean",as.character(features$V2))
        asStd<-grep("std",as.character(features$V2))
        ```

2. join the variables and sort for order, then save as dataframe with the name "colNames2".
3. Obtain the selected features plus "activity" and "subject" from the complete dataset (XYAll) and save as XYSelect

##  Adding decriptive tags
1. To keep order, add the tags by merge using XYSelect$Activity and activity$V1 as reference
..*. "Activity$V1" corresponds to the row number for each activity and it's obtained 'as is' from activity_labels.txt
2. The merged file is saved as XYDesc.
3. Obtain by subset and Apply the mean() of each subject's activities using a nested for loop.
4. on each for, the resulting mean of each activity is binded through rbind to the previous data until completed.

### Finally, save the file as "tidyData.txt"
