function SubjectData = readLogData(PathToData, DatafileName, GPSThreshold)


FID = fopen(fullfile(PathToData,DatafileName));
CStr = textscan(FID, '%s', 'delimiter', '\n');
fclose(FID);
ATTData = [];
ATTTimeStamps = [];

RAWTimeStamps = [];
RAWData = [];

FootTimeStamps = [];
FootData = [];

GPSTimeStamps = [];
GPSTimeData = [];
GPSData = [];

fprintf('Reading from file %s%s...\n', PathToData, DatafileName);

for thisrow = 1:size(CStr{1},1)-1
    oneline = char(CStr{1}(thisrow));
    %fprintf('%s\n', oneline);
    if ~isempty(oneline)
        if  strcmp('ATT', oneline(1:3))
            rowdata = textscan(oneline, '%s%d%f%f%f%f', 'Delimiter', ':,');
%             if sum(cellfun(@isempty,rowdata))>0
%                 rowdata(:) = {nan};
%             end
            rowdata(cellfun(@isempty,rowdata)) = {nan};
            TimeStamp = double(rowdata{2});
            Roll = rowdata{3};
            Pitch = rowdata{4};
            Yaw = rowdata{5};
            Heading = rowdata{6};
            ATTTimeStamps = [ATTTimeStamps; TimeStamp];
            ATTData = [ATTData; ([ Roll Pitch Yaw Heading])];
        end
        if  strcmp('RAW', oneline(1:3))
            rowdata = textscan(oneline, '%s%d%f%f%f%f%f%f%f', 'Delimiter', ':,');
%             if sum(cellfun(@isempty,rowdata))>0
%                 rowdata(:) = {nan};
%             end
            rowdata(cellfun(@isempty,rowdata)) = {nan};
            TimeStamp = double(rowdata{2});
            XGyro = rowdata{3};
            YGyro = rowdata{4};
            ZGyro = rowdata{5};
            XAcc = rowdata{6};
            YAcc = rowdata{7};
            ZAcc = rowdata{8};
            MagHeading = rowdata{9}; %not sure about this- need to check
            RAWTimeStamps = [RAWTimeStamps; TimeStamp];
            RAWData = [RAWData; ([ XGyro YGyro ZGyro XAcc YAcc ZAcc MagHeading])];
        end
        if  strcmp('FOOT', oneline(1:4))
            rowdata = textscan(oneline, '%s%d%f%f%f%f', 'Delimiter', ':,');
            %             if sum(cellfun(@isempty,rowdata))>0
            %                 rowdata(:) = {nan};
            %             end
            rowdata(cellfun(@isempty,rowdata)) = {nan};
            TimeStamp = double(rowdata{2});
            RightHeel = rowdata{3};
            RightToe = rowdata{4};
            LeftHeel = rowdata{5};
            LeftToe = rowdata{6};
            FootTimeStamps = [FootTimeStamps; TimeStamp];
            FootData = [FootData; [RightHeel RightToe LeftHeel LeftToe]];
        end
        if  strcmp('GPS', oneline(1:3))
            rowdata = textscan(oneline, '%s%d%d%d%d%f%f%f%f%f%f', 'Delimiter', ':,');
%             if sum(cellfun(@isempty,rowdata))>0
%                 rowdata(:) = {nan};
%             end
            rowdata(cellfun(@isempty,rowdata)) = {nan};
            TimeStamp = double(rowdata{2});
            GPSTime = rowdata{3};
            GPSStatus = rowdata{4};
            NumSats = rowdata{5};
            Lat = rowdata{6};
            Long = rowdata{7};
            Alt = rowdata{8};
            AltGPS = rowdata{9};
            GroundSpeed = rowdata{10};
            GPSHeading = rowdata{11};
            GPSTimeStamps = [GPSTimeStamps; TimeStamp];
            GPSTimeData = [GPSTimeData; [GPSTime GPSStatus NumSats]];
            GPSData = [GPSData; ([ Lat Long Alt AltGPS GroundSpeed GPSHeading])];
        end
        
    end
    
end

SubjectData.GPSDefines.Lat = 1;
SubjectData.GPSDefines.Long = 2;
SubjectData.GPSDefines.Alt = 3;
SubjectData.GPSDefines.AltGPS = 4;
SubjectData.GPSDefines.GroundSpeed = 5;
SubjectData.GPSDefines.GPSHeading = 6;

SubjectData.GPSTimeDefines.GPSTime = 1;
SubjectData.GPSTimeDefines.GPSStatus = 2;
SubjectData.GPSTimeDefines.NumSats = 3;


SubjectData.AttitudeDefines.Roll = 1;
SubjectData.AttitudeDefines.Pitch = 2;
SubjectData.AttitudeDefines.Yaw = 3;
SubjectData.AttitudeDefines.Heading = 4;

SubjectData.RawDefines.XGyro = 1;
SubjectData.RawDefines.YGyro = 2;
SubjectData.RawDefines.ZGyro = 3;
SubjectData.RawDefines.XAcc = 4;
SubjectData.RawDefines.YAcc = 5;
SubjectData.RawDefines.ZAcc = 6;
SubjectData.RawDefines.Headings = 7;

SubjectData.FootDefines.RightHeel = 1; %these actually switch if goofy
SubjectData.FootDefines.RightToe = 2;
SubjectData.FootDefines.LeftHeel = 3;
SubjectData.FootDefines.LeftToe = 4;


SubjectData.directory = PathToData;
SubjectData.name = DatafileName;

SubjectData.ATTData = ATTData;
SubjectData.ATTTimeStamps = ATTTimeStamps;

SubjectData.RAWTimeStamps = RAWTimeStamps;
SubjectData.RAWData = RAWData;

SubjectData.FootTimeStamps = FootTimeStamps;
SubjectData.FootData = FootData;

SubjectData.GPSTimeStamps = GPSTimeStamps;
SubjectData.GPSTimeData = GPSTimeData;
SubjectData.GPSData = GPSData;

goodLocks = find(SubjectData.GPSTimeData(:,SubjectData.GPSTimeDefines.NumSats)>GPSThreshold);
goodGPSData = find(SubjectData.GPSData(:,SubjectData.GPSDefines.Lat)>0);
goodLocks = intersect(goodLocks, goodGPSData);

SubjectData.GoodLocks = goodLocks;

fprintf('Done reading\n');