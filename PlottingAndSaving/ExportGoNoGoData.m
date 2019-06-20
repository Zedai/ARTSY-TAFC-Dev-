function success = ExportGoNoGoData(saveDir,saveFile)
%
% Copyright (c) 2010
% David M. Schneider
% Columbia University
% Department of Psychology
% July 13, 2010

if nargin < 2,
   [saveFile saveDir] = uigetfile;
end

%**************************************
% Start by loading the data
%**************************************
curdir = cd;
cd(saveDir)
load(saveFile)

%**************************************
% Parse some of the response data for easier calling
%**************************************
response = [data.response{:}];
song = [data.currentSong{:}];

% I go through a loop here to get out the time stamps because
% sometimes there is an extra empty array at the beginning
count = 1;
for i = 1:length(data.times)
    if ~isempty(data.times{i}),
        timeStamps(count,:) = [data.times{i}];
        count = count+1;
    end
end

%**************************************
% Save the data to an excel spreadsheet
%**************************************
dataMatrix(1,:) = response;
dataMatrix(2,:) = song;
dataMatrix(3,:) = timeStamps(:,3)';
dataMatrix(4,:) = timeStamps(:,4)';
dataMatrix(5,:) = timeStamps(:,6)';

cd ..
success = xlswrite(saveFile,dataMatrix');
cd(curdir)