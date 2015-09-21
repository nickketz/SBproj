function SubjectData = FindCenterOfTurns(SubjectData, GPSThreshold)

%strategy:
%use SubjectData.GPSPointsToComputeRunningAverage = 10;
%to smooth the GPSHeading data. Then go through and accumulate
% +/- SubjectData.GPSPointsToAverageForMeanDirection = 200;
% at each point to get the average direction around this point. Assign a
% mean direction to each point.
%then go through each point and compute the direction with
%function r =  circ_dist(x,y)
%comparing the point to the mean. GPS headings to the left of downhill will
%have one sign and to the right of downhill will have the opposite sign.
%Assign the sign to each point.
%finally, go through the list and assign the center of turns to the places
%where the sign changes.


GPSHeadings = SubjectData.GPSData(:,SubjectData.GPSDefines.GPSHeading);

SmoothedGPSHeadings = zeros(size(GPSHeadings));
OverallDirections = zeros(size(GPSHeadings));

LeftOrRight = zeros(size(GPSHeadings));

%now go through and find the running average of GPSHeading heading to
%smooth the data
for currentLocationIndex = 1:size(SubjectData.GoodLocks,1)
    currentLocation = SubjectData.GoodLocks(currentLocationIndex);
    StartingLocLocal = max(SubjectData.GoodLocks(1), currentLocation- SubjectData.GPSPointsToComputeRunningAverage);
    EndingLocLocal = min(SubjectData.GoodLocks(end), currentLocation + SubjectData.GPSPointsToComputeRunningAverage);
    TheseHeadingsLocal = GPSHeadings(StartingLocLocal:EndingLocLocal); %note: assumes that once get lock, it stays.
    MeanAngle = circ_rad2ang(circ_mean(circ_ang2rad(TheseHeadingsLocal)));
    SmoothedGPSHeadings(currentLocation) = MeanAngle;
    
    %now compute the overall downhill direction; estimate by larger
    %averaging over a big range of points
    StartingLoc = max(SubjectData.GoodLocks(1), currentLocation- SubjectData.GPSPointsToAverageForMeanDirection);
    EndingLoc = min(SubjectData.GoodLocks(end), currentLocation + SubjectData.GPSPointsToAverageForMeanDirection);
    TheseHeadings = GPSHeadings(StartingLoc:EndingLoc); %note: assumes that once get lock, it stays.
    MeanAngleOverall = circ_rad2ang(circ_mean(circ_ang2rad(TheseHeadings)));
    OverallDirections(currentLocation) = MeanAngleOverall;
    
    %are we left or right of the overall direction?
    LeftOrRight(currentLocation) = sign(circ_rad2ang(circ_dist(circ_ang2rad(MeanAngle), circ_ang2rad(MeanAngleOverall))));
    if ( LeftOrRight(currentLocation) == 0)
        LeftOrRight(currentLocation) = 1;
    end
    
end


%now go through and look for transitions in the LeftOrRight;
CurrentDirection = 1;
CenterOfTurns = [];
TypeOfTurn = [];
for currentLocationIndex = 1:size(SubjectData.GoodLocks,1)
    currentLocation = SubjectData.GoodLocks(currentLocationIndex);
    if LeftOrRight(currentLocation) ~= CurrentDirection && LeftOrRight(currentLocation) ~= 0
        CenterOfTurns = [CenterOfTurns currentLocation];
        CurrentDirection = LeftOrRight(currentLocation);
        TypeOfTurn = [TypeOfTurn CurrentDirection];%1 == right hand turn, -1 == left hand turn
    end
end

SubjectData.CenterOfTurns = CenterOfTurns;
SubjectData.TypeOfTurn = TypeOfTurn;
figure(1);
plot(SubjectData.GPSData(SubjectData.GoodLocks,SubjectData.GPSDefines.Lat),...
    SubjectData.GPSData(SubjectData.GoodLocks,SubjectData.GPSDefines.Long), 'b-');
hold on;
plot(SubjectData.GPSData(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==1),SubjectData.GPSDefines.Lat),...
    SubjectData.GPSData(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==1),SubjectData.GPSDefines.Long), 'r*');
hold on;
plot(SubjectData.GPSData(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==-1),SubjectData.GPSDefines.Lat),...
    SubjectData.GPSData(SubjectData.CenterOfTurns(SubjectData.TypeOfTurn==-1),SubjectData.GPSDefines.Long), 'g*');
hold off;
drawnow
%alpha_rad = circ_ang2rad(alpha_deg);       % convert to radians
%alpha_bar = circ_mean(alpha_rad);

%hcirc_rad2ang([alpha_bar]);

