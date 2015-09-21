function [Deviation, SubjectData] = FindBestShift(SubjectData, BoxData, DeviationThreshold)

%use the gps timestamps to find the offset for the start of the box data
%for every row in SubjectData, put the index for the corresponding BoxData
%entry, if it exists

APMTimestamps = double(SubjectData.GPSTimeData(:,1));
BoxTimestamps = double(BoxData.data(:,2));

%now find the offset where box time

for thistime = 1:size(APMTimestamps,1)
    
    
    [c thisIndex] = min(abs(BoxTimestamps - APMTimestamps(thistime)));
    Deviation(thistime) = abs(BoxTimestamps(thisIndex) - APMTimestamps(thistime));
    %fprintf('For APM timestamp of %d, closest box timestamp was %d, index into box is %d, deviation is %d\n', APMTimestamps(thistime), BoxTimestamps(thisIndex), thisIndex, Deviation(thistime));
    indeciesIntoBoxTimestamps(thistime) = thisIndex(1);
    %pause;
end

indeciesIntoBoxTimestamps(Deviation>DeviationThreshold)=nan;

SubjectData.indeciesIntoBoxTimestamps = indeciesIntoBoxTimestamps;
SubjectData.Deviation = Deviation;
SubjectData.BoxData = BoxData;

%now copy over data into correct rows
for thistime = 1:size(APMTimestamps,1)
    if ~isnan(indeciesIntoBoxTimestamps(thistime))
        SubjectData.FootTimeStamps(thistime,1) = BoxTimestamps(indeciesIntoBoxTimestamps(thistime));
        SubjectData.FootData(thistime, :) = BoxData.data(indeciesIntoBoxTimestamps(thistime), find(strcmp([BoxData.colheaders], ' RightHeel')): find(strcmp([BoxData.colheaders], ' LeftToe')));
    else
        SubjectData.FootTimeStamps(thistime,1) = 0;
        SubjectData.FootData(thistime, :) = [0 0 0 0];
        
    end
end
