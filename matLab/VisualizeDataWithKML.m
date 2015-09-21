%load data first...
clear all
close all

DefineTypes;%loads in constants for plotting types

SubjectName = 'OwenBuseyMarch2013'; %can be anything
PathToData = 'data/OwenDataFromFrisco/';%this is the folder name on the hard drive

eval(sprintf('load %s%sAllRunsAndDays.mat AllRunsAndDays', PathToData, SubjectName));

DataToVisualize = GROUNDSPEED;
DataToVisualize = TOEMINUSHEEL;

for dayindex = 1:length(AllRunsAndDays.DayList)
    day = AllRunsAndDays.DayList(dayindex);
    for run = 1:size(AllRunsAndDays.Days{day}.RunData,2)
          SubjectData =  AllRunsAndDays.Days{day}.RunData{run};
        ExportToKML(SubjectData, DataToVisualize, sprintf('%sDay%d/', AllRunsAndDays.PathToData, day));
    end
end

