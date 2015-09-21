PathToData = 'Data/Jackson/';
PathToData = 'Data/';
PathToData = 'data/DataFromFrisco/Day2/BoxArdupilot/';
PathToShoulderData = 'data/DataFromFrisco/Day2/SholderArduPilot/';
PathToBoxData = 'data/DataFromFrisco/Day2/BoxSDCard/';
close all

addpath('kmltoolbox_v2.3');
addpath('colorspace');
addpath('CircStat2012a');

DatafileName = '2013.02.04 @ 13.51-3.csv';

DatafileName = '2013.03.12 @ 19.30-1.csv';
ShoulderDatafileName = '2013.03.12 @ 20.00-1.csv';

BoxDatafileName = '1.CSV';



%need to save in new version of box 1:
%magnometer heading
%GPS timestamp
%save files using leading zeros

GPSThreshold = 3;%need 7 or more sats for good fix
DeviationThreshold = 300; %if box GPS time doesn't fall within 300 ms of apm time, assume bad match

GPSPointsToAverageForMeanDirection = 75;
GPSPointsToComputeRunningAverage = 5;

DefineTypes;



DataToVisualize = GROUNDSPEED;
DataToVisualize = TOEMINUSHEEL;

d = dir([PathToData, '*.csv']);

%for thisfile = 1:length(d)%
for thisfile = 1
    DatafileName = d(thisfile).name;
    SubjectData = readLogData(PathToData, DatafileName, GPSThreshold);
    % SubjectDataShoulder = readLogData(PathToShoulderData, ShoulderDatafileName, GPSThreshold);
    BoxData = readBoxData(PathToBoxData, BoxDatafileName);
    
    [SubjectData] = FindBestShift(SubjectData, BoxData, DeviationThreshold);
    
    EndGPSTime = SubjectData.GPSTimeData(end,1);
    EndGPSTime = EndGPSTime/1000;
    
    SubjectData.GPSPointsToAverageForMeanDirection = GPSPointsToAverageForMeanDirection;
    SubjectData.GPSPointsToComputeRunningAverage = GPSPointsToComputeRunningAverage;
    
    SubjectData = FindCenterOfTurns(SubjectData, GPSThreshold);
    
    
    
    ExportToKML(SubjectData, DataToVisualize, PathToData);
    %PlotLatLong(SubjectData,GPSThreshold);
    
    %pause
end