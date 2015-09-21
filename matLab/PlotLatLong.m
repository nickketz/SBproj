function PlotLatLong(SubjectData, GPSThreshold)
goodLocks = find(SubjectData.GPSTimeData(:,3)>GPSThreshold);
goodGPSData = find(SubjectData.GPSData(:,1)>0);
goodLocks = intersect(goodLocks, goodGPSData);
plot(SubjectData.GPSData(goodLocks,1), SubjectData.GPSData(goodLocks, 2));
title(sprintf('Subject %s', SubjectData.name));