function SubjectData = SearchForBoxData(SubjectData, PathToBoxData, DeviationThreshold)

%idea is to search through the box data to find a file that has timestamps
%near the gps timestamps of our APM data. If so, load that data.

d = dir([PathToBoxData, '*.CSV']);

for thisfile = 1:size(d,1);
    BoxDatafileName = d(thisfile).name;
    
    BoxData = readBoxData(PathToBoxData, BoxDatafileName);
    if isfield(BoxData, 'colheaders');
        
        [Deviations] = FindBestShift(SubjectData, BoxData, 10000000);
        NumGoodDeviations = sum(Deviations<DeviationThreshold);
        
        if (NumGoodDeviations) > length(Deviations)/4 %at least 1/4 of the box data should be good
            [Deviations, SubjectData] = FindBestShift(SubjectData, BoxData, DeviationThreshold);
            fprintf('Found matching data from file %s\n\n\n', [PathToBoxData, BoxDatafileName]);
            return
        end
    end
end
fprintf('Found no matching box data for this run\n\n\n');