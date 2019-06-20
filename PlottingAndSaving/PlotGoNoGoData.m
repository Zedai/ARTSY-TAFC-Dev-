function PlotGoNoGoData(saveDir,saveFile)
%
% Copyright (c) 2010
% David M. Schneider
% Columbia University
% Department of Psychology
% July 13, 2010

%**************************************
% Start by loading the data
%**************************************
curdir = cd;
cd(saveDir)
load(saveFile)
cd(curdir)

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
% Run through each song and compute the % correct
% First go through all go songs
% Then go through all no-go songs
%**************************************
resultAll = nan*ones(size(response));
for i = 1:data.nGo,
    %Find all the correct and incorrect responses for this song
    HIT = intersect(find(response==1),find(song==i));
    MISS = intersect(find(response==0),find(song==i));
    trials{i} = sort([HIT MISS]);
    
    %Keep track of the record across all songs
    resultAll(HIT) = 1;
    resultAll(MISS) = 0;
    
    %calculate the correct/incorrect vector for this song
    correct{i} = nan*ones(size(response));
    correct{i}(HIT) = 1;
    correct{i}(MISS) = 0;
    correct{i} = correct{i}(find(~isnan(correct{i})));
end
for i = 1:data.nNoGo,
    %Find all the correct and incorrect responses for this song
    HIT = intersect(find(response==0),find(song==i+data.nGo));
    MISS = intersect(find(response==1),find(song==i+data.nGo));
    trials{i+data.nGo} = sort([HIT MISS]);
    
    %Keep track of the record across all songs
    resultAll(HIT) = 1;
    resultAll(MISS) = 0;
    
    %calculate the correct/incorrect vector for this song
    correct{i+data.nGo} = nan*ones(size(response));
    correct{i+data.nGo}(HIT) = 1;
    correct{i+data.nGo}(MISS) = 0;
    correct{i+data.nGo} = correct{i+data.nGo}(find(~isnan(correct{i+data.nGo})));
end

%**************************************
% Plot the data
%**************************************
figure
filtLength = 10;

%First, plot the running averages across all song types
subplot(1,2,1)
% smoother = 100*ones(1,filtLength)/filtLength;
% smoothedData2 = convn(resultAll,smoother,'same');
for i = 1:length(resultAll),
    smoothedData(i) = 100*sum(resultAll(max(1,i-(filtLength-1)):i))/min(i,filtLength);
end
plot(1:length(resultAll),smoothedData,'k-');
hold on
plot([1 length(resultAll)],[50 50],'r--')
axis([1 length(resultAll) -5 105])
xlabel('Trial #')
ylabel('Percent Correct')
title(saveFile,'Interpreter','None')

%First, plot the running averages across all song types
subplot(1,2,2)
lineDef = [{'-'},{'--'},{'-.'},{':'},{'-'},{'--'},{'-.'},{':'}];
for i = 1:data.nGo,
%     smoother = 100*ones(1,filtLength)/filtLength;
%     smoothedData2 = convn(correct{i},smoother,'same');
    clear smoothedData
    for j = 1:length(correct{i}),
        smoothedData(j) = 100*sum(correct{i}(max(1,j-(filtLength-1)):j))/min(j,filtLength);
    end
    plot(trials{i},smoothedData,['b',lineDef{i}]);
    hold on
end
for i = 1:data.nNoGo,
%     smoother = 100*ones(1,filtLength)/filtLength;
%     smoothedData2 = convn(correct{i+data.nGo},smoother,'same');
    clear smoothedData
    for j = 1:length(correct{i+data.nGo}),
        smoothedData(j) = 100*sum(correct{i+data.nGo}(max(1,j-(filtLength-1)):j))/min(j,filtLength);
    end
    plot(trials{i+data.nGo},smoothedData,['r',lineDef{i}]);
    hold on
end
plot([1 length(resultAll)],[50 50],'k--')
axis([1 length(resultAll) -5 105])
xlabel('Trial #')
ylabel('Percent Correct')
title('Blue = GO, Red = NO-GO')

