clear all
close all

DefineTypes;%loads in constants for plotting types

SubjectName = 'OwenBuseyMarch2013'; %can be anything
PathToData = 'data/OwenDataFromFrisco/';%this is the folder name on the hard drive

eval(sprintf('load %s%sAllRunsAndDays.mat AllRunsAndDays', PathToData, SubjectName));

markerType = {'*', '^', '.'};

timepointsBeforeTurnToPlot = 20;
timepointsAfterTurnToPlot = 20;

TypesOfTurns = [-1 1];%-1 is to the left (on the right side of the run facing downhill)

numDays = size(AllRunsAndDays.DayList,2);

DataToVisualize = HEADINGINCOLOR; %change this To anything defined below in all caps
 
for day = 1:numDays
    SumOverTurns = zeros(size(TypesOfTurns,2), timepointsBeforeTurnToPlot + timepointsAfterTurnToPlot + 1);
    CountsOverTurns = zeros(size(TypesOfTurns,2), timepointsBeforeTurnToPlot + timepointsAfterTurnToPlot + 1);
    TimeBase = [-1 * timepointsBeforeTurnToPlot : timepointsAfterTurnToPlot];
    
    
    for runNumber = 1:size(size(AllRunsAndDays.Days{day}.RunData),2)
        
        SubjectData = AllRunsAndDays.Days{day}.RunData{runNumber}; %represents one run of data
        
        CenterOfTurns = SubjectData.CenterOfTurns;
        TypeOfTurns = SubjectData.TypeOfTurn;
        
        %now plot the raw foot data with center and type of turns overplotted
        goodLocks = SubjectData.GoodLocks;
        goodLocks = goodLocks(1:end-10); %may have one fewer entry for ATT and Raw

        % RawData = SubjectData.FootData(goodLocks,2) + SubjectData.FootData(goodLocks,4) - SubjectData.FootData(goodLocks,1) - SubjectData.FootData(goodLocks,3);
        if DataToVisualize == TOEMINUSHEEL
            GyroSum = SubjectData.FootData(goodLocks,2) + SubjectData.FootData(goodLocks,4) - SubjectData.FootData(goodLocks,1) - SubjectData.FootData(goodLocks,3);
        end
        
        if DataToVisualize == GROUNDSPEED
            GyroSum = (SubjectData.GPSData(goodLocks,5));%gps ground speed
        end
        if DataToVisualize == HEADINGINCOLOR
            GyroSum = (mod(SubjectData.GPSData(goodLocks,6)+180, 360));%gps heading
        end
        if DataToVisualize == XGYRO
            GyroSum = (SubjectData.RAWData(goodLocks,1));%gyros
        end
        if DataToVisualize == ROLL %only works for day 3 for owen
            GyroSum = (SubjectData.ATTData(goodLocks,1));%roll
            
        end
        
        
        if ~isempty(GyroSum)
            
            
            
            %now find the center of every left turn
            for turnType = 1:2
                
                turnsOfThisType = find(TypeOfTurns == TypesOfTurns(turnType));%check this
                
                
                for turn = 1:size(turnsOfThisType,2)
                    
                    %this gives the index into CenterOfTurns, which indexes into the list
                    %of raw data
                    thisTurn = CenterOfTurns(turnsOfThisType(turn));
                    %now go through and crop out raw data before and after this point
                    
                    if thisTurn - timepointsBeforeTurnToPlot > 0 && thisTurn + timepointsAfterTurnToPlot <= size(GyroSum,1)
                        SumOverTurns(turnType, :) = SumOverTurns(turnType, :) + GyroSum(thisTurn - timepointsBeforeTurnToPlot: thisTurn + timepointsAfterTurnToPlot)';
                        CountsOverTurns(turnType, :) = CountsOverTurns(turnType, :) + ones (size(GyroSum(thisTurn - timepointsBeforeTurnToPlot: thisTurn + timepointsAfterTurnToPlot)'));
                    end
                end
                
                
                
            end
        end
    end
    markerToUse = sprintf('r%s-', char(markerType{day}));
    plot(TimeBase, SumOverTurns(1,:)./CountsOverTurns(1,:), markerToUse);
    hold on
    markerToUse = sprintf('g%s-', char(markerType{day}));
    
    plot(TimeBase, SumOverTurns(2,:)./CountsOverTurns(2,:), markerToUse);
    hold on
    
    
end
legendSTR = ['legend('];
for day = 1:numDays
    legendSTR = [legendSTR sprintf('''Day %d Left'',', day)];
    legendSTR = [legendSTR sprintf('''Day %d Right'',', day)];
    
end
legendSTR = legendSTR(1:end-1);
legendSTR = [legendSTR ');'];
eval(legendSTR);

title(sprintf('Data from %s, %s', SubjectName, SaveNames{DataToVisualize}));
