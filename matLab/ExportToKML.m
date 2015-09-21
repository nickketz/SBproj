function ExportToKML(SubjectData, DataToVisualize, PathToData)

DefineTypes;%loads in constants

goodLocks = SubjectData.GoodLocks;
figure(1)
plot(SubjectData.GPSData(goodLocks,1), SubjectData.GPSData(goodLocks, 2));
title(sprintf('Subject %s', SubjectData.name));
goodLocks = goodLocks(1:end-10); %may have one fewer entry for ATT and Raw
if ~isempty(goodLocks)
    
    if DataToVisualize == GROUNDSPEED
        GyroSum = (SubjectData.GPSData(goodLocks,5));%gps ground speed
        MaxGyroSum = max(GyroSum);
        MinGyroSum = min(GyroSum);
    end
    if DataToVisualize == HEADINGINCOLOR
        GyroSum = (mod(SubjectData.GPSData(goodLocks,6)+180, 360));%gps heading
    end
    if DataToVisualize == XGYRO
        GyroSum = (SubjectData.RAWData(goodLocks,1));%gyros
    end
    if DataToVisualize == ROLL
        GyroSum = (SubjectData.ATTData(goodLocks,1));%roll
        MaxGyroSum = 25;%for roll
        MinGyroSum = -25;
        
    end
    
    if DataToVisualize == TOEMINUSHEEL
        if ~isempty (SubjectData.FootData)
            GyroSum = SubjectData.FootData(goodLocks,2) + SubjectData.FootData(goodLocks,4) - SubjectData.FootData(goodLocks,1) - SubjectData.FootData(goodLocks,3);
            MaxGyroSum = max(GyroSum);
            MinGyroSum = min(GyroSum);
        else
            GyroSum = ones(size(goodLocks));
            MaxGyroSum = 1;
            MinGyroSum = 0;
        end
    end
    
    
    %GyroSum = (SubjectData.ATTData(goodLocks,2));%pitch
    %GyroSum = (mod(SubjectData.ATTData(goodLocks,4)+180, 360));%magnometer heading
    
    %    GyroSum(1:end-1)=GyroSum(2:end)-GyroSum(1:end-1);
    %  GyroSum(end) = mean(GyroSum);
    
    %MaxGyroSum = 20;%for pitch
    %MinGyroSum = -20;
    
    
    figure(1)
    hist(GyroSum,100);
    %pause
    
    GyroSum = (GyroSum-MinGyroSum)/(MaxGyroSum-MinGyroSum);
    GyroSum(find(GyroSum>1))=1;
    GyroSum(find(GyroSum<0))=0;
    
else
    GyroSum = ones(size(SubjectData.GPSTimeData(:,3),1),1);
end


%GyroSum=5*(GyroSum-.5)+.5;
%GyroSum(GyroSum<0)=0;
%GyroSum(GyroSum>1)=1;

% Create a new kml object
k = kml([PathToData 'KMLFiles/' SubjectData.name sprintf('%s', SaveNames{DataToVisualize})]);
%plot(SubjectData.GPSData(goodLocks,1), SubjectData.GPSData(goodLocks, 2));

numLinks = length(GyroSum);
numTurnsRight = length(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==1));
numTurnsLeft = length(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==-1));%
if 1
    
    k.scatter3( SubjectData.GPSData(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==1), SubjectData.GPSDefines.Long), SubjectData.GPSData(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==1),SubjectData.GPSDefines.Lat), linspace(0,1e6,numTurnsRight).', 'altitudeMode',  'clampToGround', 'name','Right Turns',...
        'iconScale',.3,'iconColor',[zeros(numTurnsRight,1) ones(numTurnsRight,1)  zeros(numTurnsRight,1) ones(numTurnsRight,1)   ]);
    k.scatter3( SubjectData.GPSData(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==-1), SubjectData.GPSDefines.Long), SubjectData.GPSData(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==-1),SubjectData.GPSDefines.Lat), linspace(0,1e6,numTurnsLeft).', 'altitudeMode',  'clampToGround', 'name','Left Turns',...
        'iconScale',.3,'iconColor',[zeros(numTurnsLeft,1) zeros(numTurnsLeft,1)  ones(numTurnsLeft,1) ones(numTurnsLeft,1)   ]);
    k.scatter3( SubjectData.GPSData(goodLocks, SubjectData.GPSDefines.Long), SubjectData.GPSData(goodLocks,SubjectData.GPSDefines.Lat), linspace(0,1e6,numLinks).', 'altitudeMode',  'clampToGround', 'name','GPS Track',...
        'iconScale',.2,'iconColor',[(GyroSum) zeros(numLinks,1)  zeros(numLinks,1) ones(numLinks,1)   ]);
    
end

%kml.model(longitude, latitude, altitude, heading, tilt, roll)
%kml.model(...,'PropertyName',PropertyValue,...)
if 0
    k.model( SubjectData.GPSData(goodLocks, 2), SubjectData.GPSData(goodLocks,1),linspace(0,1e6,numLinks).',...
        ((SubjectData.ATTData(goodLocks,4))+90), SubjectData.ATTData(goodLocks,2), SubjectData.ATTData(goodLocks,1)+180,'altitudeMode',  'clampToGround','model','Snowboarder.dae','scale',500);
end


% Save the kml and open it in Google Earth
k.run;
