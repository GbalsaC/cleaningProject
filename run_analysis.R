run_analysis <- function(path=".", folder="Dataset"){
        message(paste("Actual path is: ", getwd(), "+ ",path, sep=""));
        message(paste("Trying to fetch data in '",folder,"' folder in path \n"));
        if(length(grep(folder, list.files(path)))==0){
                warning(paste("Folder 'Dataset' not found in path, ","\n reverting to original name 'UCI HAR Dataset'"))
                folder<-"UCI HAR Dataset";
                ##Changes the name of the folder
                }else{
                        numberTemp<-grep(folder, list.files(path));
                        message(paste(folder, " found in path ", list.files(path)[numberTemp],"\n"))
                }
        if(length(grep(folder, list.files(path)))==0){
                stop(paste("Neither folder labels: '",folder, "'or ","'Dataset' were found on path or working directory...", "please use original assignment folder structure \n"));
        }
        else{
                #Enters here with 'Dataset' and "UCI HAR Dataset" as folder names or both
                numberTemp<-grep(folder, list.files(path));
                message(paste("Folder found as: ", list.files(path)[numberTemp], "\n"))
                if(length(numberTemp)>1){
                        warning("Two folders including 'Dataset' label found, function proceeds \n");
                        if(list.files(path)[numberTemp[1]]=="Dataset" || list.files(path)[numberTemp[1]]=="UCI HAR Dataset" || list.files(path)[numberTemp[2]]=="Dataset" || list.files(path)[numberTemp[2]]=="UCI HAR Dataset" ){
                                if(list.files(path)[numberTemp[1]]=="Dataset" || list.files(path)[numberTemp[2]]=="Dataset"){
                                        folder='Dataset';
                                        message(paste("Using: ",folder));
                                }else{
                                        if(list.files(path)[numberTemp[1]]=="UCI HAR Dataset" || list.files(path)[numberTemp[2]]=="UCI HAR Dataset"){
                                                folder='UCI HAR Dataset';
                                                message(paste("Using: ",folder));
                                        }else{
                                                stop("[001] The folder name is not exactly 'Dataset' or 'UCI HAR Dataset', please verify as folders in path \n"); 
                                        }     
                                }
                                
                        }else{
                                stop("The folder name is not exactly 'Dataset' or 'UCI HAR Dataset', please verify as folders in path \n");
                        }
                
                }else{
                        if(list.files(path)[numberTemp]!="UCI HAR Dataset" && list.files(path)[numberTemp]!="Dataset"){
                                stop("The folder name is not the same as original, please verify as 'UCI HAR Dataset'");
                        }     
                }
        }
        folder;
        print(paste("New path is: ",path,"/",folder,sep=""));
        files<-list.files(paste(path,"/",folder,sep=""));
        if(length(files)==0){stop("Oh my Glob... There's nothing here!")}
        
        ##Else is just executed secuentially, verify text files are in appropiate order.
        path<-paste(path,"/",folder,sep="");
        path.train<-paste(path,"/train", sep="")
        path.test<-paste(path,"/test", sep="")
        ##New path for quering items
        ##Must find all 6 files or send error
        files<-list.files(path)
        files.train<-list.files(path.train)
        files.test<-list.files(path.test)
                ##Separate Files into R Objects
        #Separate Train files
        
        numberTemp<-grep("X_train", files.train);
        fileTemp<-paste(path.train,"/",files.train[numberTemp],sep="");
        print(fileTemp)
        xTrain<-read.table(file=fileTemp, sep="");
        numberTemp<-grep("y_train", files.train)
        fileTemp<-paste(path.train,"/",files.train[numberTemp],sep="");
        print(fileTemp)
        yTrain<-read.table(file=fileTemp, sep="");
        numberTemp<-grep("subject_train", files.train);
        fileTemp<-paste(path.train,"/",files.train[numberTemp],sep="");
        print(fileTemp)
        subTrain<-read.table(file=fileTemp, sep="");
        
        #Separate Test files
        numberTemp<-grep("y_test", files.test)
        fileTemp<-paste(path.test,"/",files.test[numberTemp],sep="");
        print(fileTemp)
        yTest<-read.table(file=fileTemp, sep="")
        numberTemp<-grep("X_test", files.test)
        fileTemp<-paste(path.test,"/",files.test[numberTemp],sep="");
        print(fileTemp)
        xTest<-read.table(file=fileTemp, sep="")
        numberTemp<-grep("subject_test", files.test)
        fileTemp<-paste(path.test,"/",files.test[numberTemp],sep="");
        print(fileTemp)
        subTest<-read.table(file=fileTemp, sep="")

        #Root Folder features & Activity, features might reutrn two values, use first
        numberTemp<-grep("activity_labels", files)
        fileTemp<-paste(path,"/",files[numberTemp],sep="");
        print(fileTemp)
        activity<-read.table(file=fileTemp, sep="")
        numberTemp<-grep("features", files)
        fileTemp<-paste(path,"/",files[numberTemp[1]],sep="");
        print(fileTemp)
        features<-read.table(file=fileTemp, sep="")
        
        ##Set names to Variable lists
        namesList<-features$V2;
        names(xTest)<-namesList;
        names(xTrain)<-namesList;
        names(yTest)<-"Activity";
        names(yTrain)<-"Activity";
        names(subTrain)<-"Subject";
        names(subTest)<-"Subject";
        
        ##Join Columns, Activity Column must be first for Apply function
        XYTest<-cbind(yTest,subTest,xTest)
        XYTrain<-cbind(yTrain,subTrain,xTrain)
        XYAll<-rbind(XYTrain,XYTest)
        
        
        #Prepare for extraction of only Mean and STD measurements
        asMean<-grep("mean",as.character(features$V2))
        asStd<-grep("std",as.character(features$V2))
        #Reassign as dataFrames for merging
        dim(asMean)<-c(length(asMean),1)
        dim(asStd)<-c(length(asStd),1)
        
        #ColSelect works as extraction config, must be ordered
        #Remember to call from ColNames since XYAll already has
        #Subject and Activity as first columns
        colselect<-rbind(asStd,asMean)
        sort(colselect)
        colNames<-features[colselect,2]
        colNames2<-c("Activity","Subject", as.character(colNames))
        print(head(colNames2));
        colNames2<-as.data.frame(colNames2)
        print(head(colNames2[,1]));
        XYSelect<-XYAll[,colNames2[,1]]
        #After, 'Activity' will be sorted between the data.frame
        ##Reorder Subject and Activity to second and first
        found<-grep("Subject",names(XYSelect))
        #Subject First
        if(found!=1){
                after<-(found+1):length(names(XYSelect))
                before<-1:found-1
                XYSelect<-XYSelect[,c(found,before,after)]     
        }
        #Then Activity to first column
        found<-grep("Activity",names(XYSelect))
        if(found!=1){
                after<-(found+1):length(names(XYSelect))
                before<-1:found-1
                XYSelect<-XYSelect[,c(found,before,after)]     
        }
        
        
        #After Merge Columns for Activity Description
        XYDesc<-merge(XYSelect, activity, by.x="Activity",by.y="V1", sort=F)
        #Give Descriptive Value to Activity and eliminate extra column
        XYDesc[,"Activity"]<-XYDesc[,"V2"]
        XYDesc<-XYDesc[,1:length(names(XYDesc))-1]
        
        ##Give Temp Values forFor Loop 
        #numFill1 is for subjects
        #numFill2 is for Activities
        toSave<-data.frame()
        activityList<-activity$V2      #is Factor
        activityList<-levels(activityList) #Is Vector
        numFill1<-as.numeric(levels(as.factor(XYDesc$Subject)))
        numFill2<-activity$V1
        for(i in numFill1){
                for(j in numFill2){
                        newVar<-subset(XYDesc, Subject==i & Activity==activityList[j])
                        
                        tempRow<-apply(newVar[,2:ncol(newVar)], 2, mean)
                        namesList<-names(tempRow);
                        namesList<-c("Activity",namesList);
                        
                        #Dimensions, saved as single row multicolumn per activity
                        dim(tempRow)<-c(1,length(tempRow)) #looses Names
                        tempRow<-cbind(activityList[j], tempRow);
                        tempRow<-as.data.frame(tempRow);
                        toSave<-rbind(toSave,tempRow);
                }
                
        }
        names(toSave)<-names(XYDesc)
        write.table(toSave, file="tidyData.txt", row.names=F);
        message("File saved as 'tidyData.txt in workdirectiry")
        
        #Return
        toSave
}