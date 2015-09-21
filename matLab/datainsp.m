%notes from 9.21.15
mydir = 'data/Expert 1/13.51/';
files = dir([mydir '/*.csv']);
files = {files.name};

sesnums = nan(length(files),1);

inds = regexp(files,'[0-9].csv');
for i = 1:length(files)
    sesnums(i) = str2num(files{i}(20:inds{i}));
end
[sesnums,index] = sort(sesnums);
files = files(index);

tmp = readLogData(mydir,files{2},4);

time = tmp.GPSTimeData;
time = time-time(0);
mins = time/(60*1000);

plot(mins,tmp.GPSData);
legend(tmp.GPSDefines,'fontsize',20);

