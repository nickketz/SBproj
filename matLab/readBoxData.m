function    BoxData = readBoxData(PathToBoxData, BoxDatafileName)


[BoxData,delimiterOut,headerlinesOut] = importdata([PathToBoxData BoxDatafileName], ',', 1);
%fprintf('Data loaded from %s\n', [PathToBoxData BoxDatafileName]);