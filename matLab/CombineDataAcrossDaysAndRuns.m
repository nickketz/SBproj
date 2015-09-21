

%need to list the filenames across days and runs for each subject
%won't be necessary when have just one APM that records everything
%not using the shoulder APM now
SubjectName = 'OwenBuseyMarch2013'; %can be anything
PathToData = 'data/OwenDataFromFrisco/';%this is the folder name on the hard drive
PathToAPMData = 'BoxArdupilot/';
PathToBoxData = 'BoxSDCard/';
DayList = [1 2 3]; %list the days the subject ran, starting with 1 (can have only 1)

%end of things to edit

close all

addpath('kmltoolbox_v2.3');
addpath('colorspace');
addpath('CircStat2012a');


GPSThreshold = 3;%need 7 or more sats for good fix
DeviationThreshold = 300; %if box GPS time doesn't fall within 300 ms of apm time, assume bad match

GPSPointsToAverageForMeanDirection = 75;
GPSPointsToComputeRunningAverage = 5;

DefineTypes;

AllRunsAndDays.SubjectName = SubjectName;
AllRunsAndDays.PathToData = PathToData;
AllRunsAndDays.DayList = DayList;
AllRunsAndDays.GPSThreshold = GPSThreshold;
AllRunsAndDays.DevitionThreshold = DeviationThreshold;
AllRunsAndDays.GPSPointsToAverageForMeanDirection = GPSPointsToAverageForMeanDirection;
AllRunsAndDays.GPSPointsToComputeRunningAverage = GPSPointsToComputeRunningAverage;

for dayindex = 1:length(DayList)
    day = DayList(dayindex);
    %for day = 2
    d = dir([sprintf('%sDay%d/%s', PathToData, day, PathToAPMData), '*.csv']);
    
    numRuns = size(d,1);
    
   % for run = 1:1
    for run = 1:numRuns
        DatafileName = d(run).name;
        
        %DatafileName = char(APMDataFileNames{day}.Runs{run});
        SubjectData = readLogData(sprintf('%sDay%d/%s', PathToData, day, PathToAPMData), DatafileName, GPSThreshold);
        SubjectData = SearchForBoxData(SubjectData, sprintf('%sDay%d/%s', PathToData, day, PathToBoxData), DeviationThreshold);
         SubjectData.GPSPointsToAverageForMeanDirection = GPSPointsToAverageForMeanDirection;
        SubjectData.GPSPointsToComputeRunningAverage = GPSPointsToComputeRunningAverage;
        SubjectData = FindCenterOfTurns(SubjectData, GPSThreshold);
     
        AllRunsAndDays.Days{day}.RunData{run} = SubjectData;
    end
end

eval(sprintf('save %s%sAllRunsAndDays.mat AllRunsAndDays', PathToData, SubjectName));

