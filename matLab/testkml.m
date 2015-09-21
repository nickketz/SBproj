% Create a new kml object
k = kml('my kml file');

% Creates a random 3D scatter plot in the kml
k.scatter3(360*rand(100,1)-180,180*rand(100,1)-90,linspace(0,1e6,100).','iconScale',linspace(5,10,100).','iconColor',[zeros(100,1)  linspace(0,1,100).' zeros(100,1) linspace(0,1,100).'])

% Save the kml and open it in Google Earth
k.run;