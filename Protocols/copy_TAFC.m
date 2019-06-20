function varargout = TAFC(varargin)
% The following code controls the Two-Alternative Forced Choice task.
%
% Copyright (c) 2010
% David M. Schneider
% Columbia University
% Department of Psychology
% July 13, 2010

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN MATLAB INITIALIZATION (DO NOT EDIT!)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TAFC_OpeningFcn, ...
                   'gui_OutputFcn',  @TAFC_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROTOCOL SPECIFIC INITIALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TAFC_OpeningFcn(hObject, eventdata, handles, varargin)
% Set up the default parameters for the program
% NI = daqhwinfo('nidaq');
% handles.dio = digitalio(NI.AdaptorName, [NI.InstalledBoardIds{1}]);
% addline(handles.dio, 0:7, 0, 'Out'); %Pins 47-33
% addline(handles.dio, 0:7, 1, 'Out'); %Pins 31-17
% addline(handles.dio, 0:7, 2, 'In'); %Pins 15-1
% putvalue(handles.dio.Line([9:16]), [1 1 1 1 1 1 1 1]);

protocol = 'TAFC';

% Initialize the protocol
[hObject, eventdata, handles] = InitializeProtocol(protocol,hObject, eventdata, handles);

% Choose default command line output for Shaping
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StartStopButton_Callback(hObject, eventdata, handles)
% This is the main code for the protocol

% Decide if the program was just started or stopped
handles.startOrStop = get(hObject,'Value');

% Read the settings from the GUI
handles = ReadSettings(handles);

% Write some settings to the GUI
set(handles.filenameDisplay,'String',handles.saveFile)
set(handles.statusDisplay,'String','Press START/STOP to begin task...')
pause(0.01)

% START the task if toggle button was turned on
if handles.startOrStop == 1 && handles.running == 0,
    % Make sure that a booth is selected
    % If not, tell the user and break out of the program
    if handles.booth == 0,
        disp('NO BOOTH SELECTED!')
        handles.running = 0; 
        handles.reset = 0;
        guidata(hObject, handles);
        return
    end
    
    % Start the program:
    disp('START')
    StartWaiting = 1;
    handles.running = 1;
    handles.reset = 0;
    
    %Build an initial block of trials
    [handles.stims, handles.nGo1, handles.nGo2, handles.blockSize, handles.song, handles.songNames, handles.bigBlockSize, handles.reinforceSchedule]...
        = buildBlock(hObject, eventdata, handles);
    
        pinActive = randi(2);   %Sai (redundancy, should never actually use this value instantiated here)
                   
        boothStatus.led = 1;
        boothStatus.led2 = 1;

        first = true;
    % Wait for the bird to initiate a trial
    while handles.startOrStop == 1,
        pinCheck = [1,1];                                               % Added by Efe Soyman.

        % On the first pass through the while loop, display status
        if StartWaiting,
            disp('Waiting for initiation...')
            set(handles.statusDisplay,'String','Waiting for initiation...')
            StartWaiting = 0;
        end
        
        % Check for trial initiation
        tryflag = 1;
        while tryflag,
            try
                eval(['load key',num2str(handles.booth),'Status'])
                tryflag = 0;
            catch
                tryflag = 1;
                disp(['Error while reading key ',num2str(handles.booth)]);
            end
        end
        %pinCheck = [keyStatus.key1, keyStatus.key2];
        % pinCheck = and(pinCheck1,pinCheck2);
        if(~first)
            boothStatus.led = pinActive == 1;   % Sai
            boothStatus.led2 = pinActive == 2;  % Sai
        end
        
        % Check for whether the program has been paused
        pause(0.01)
        handles.startOrStop = get(hObject,'Value');
        pause(0.01)
              
        % "EFE"
        try
            pinCheck = [keyStatus.key1, keyStatus.key2];
        catch
            disp('keyStatus doesn''t exist');
            keyStatus.key1 = 1;
            keyStatus.key2 = 1;
            pinCheck = [keyStatus.key1, keyStatus.key2];
        end

        % If the bird pecked a key, run the trial
        if (pinCheck(pinActive) < 0.5 && handles.startOrStop) || ((pinCheck(1)<0.5||pinCheck(2)<0.5)&&first&&handles.startOrStop),   %Sai
            
            songPick = handles.stims(handles.trialNumLocal);
            reinforce = handles.reinforceSchedule(handles.trialNumLocal);
            if handles.verbose == 1,
                disp(' ');
                disp(['BEGIN TRIAL ',num2str(handles.trialNum)]);
                disp(['Stimulus #:  ',num2str(songPick)]);
            end
            set(handles.statusDisplay,'String','Trial running...')

            % RUN THROUGH A SINGLE TRIAL
            [t iti response reward punish respCategory tLabels pinActive] = TAFCTrial(handles,songPick,reinforce);
            first = false;
            %Keep track of timing information
            handles.data.times{handles.trialNum} = t;
            handles.data.iti{handles.trialNum} = iti;
            handles.data.response{handles.trialNum} = response;
            handles.data.outcome{handles.trialNum} = [reward punish];
            handles.data.currentSong{handles.trialNum} = songPick;
            handles.data.currentSongName{handles.trialNum} = handles.songNames{songPick};

            %Keep track of how many trials in each category
            handles = UpdateStats(handles,respCategory,reward,punish);

            %Repeat the previous trial if necessary
            if handles.repeat == 1 && (respCategory == 2 || respCategory == 4),
                handles.trialNumLocal = handles.trialNumLocal;
                handles.nRepeats = handles.nRepeats + 1;
            else
                handles.trialNumLocal = handles.trialNumLocal + 1;
                handles.nRepeats = handles.nRepeats;
            end

            %Build a new block if we went all the way through the previous
            %block
            set(handles.nRepeatsDisplay,'String',num2str(handles.nRepeats));
            if handles.trialNumLocal > handles.bigBlockSize,
                %Build a new block
                [handles.stims, handles.nGo1, handles.nGo2, handles.blockSize, handles.song, handles.songNames, handles.bigBlockSize, handles.reinforceSchedule]...
                    = buildBlock(hObject, eventdata, handles);
                handles.trialNumLocal = 1;
                handles.blockNum = handles.blockNum + 1;
            end
            StartWaiting = 1;
            pause(0.01); %Necessary to reload the trial #
            
                        % "Sai Basilio"
            handles.data.booth = handles.booth;
            handles.data.nGo1 = handles.nGo1;
            handles.data.nGo2 = handles.nGo2;
            handles.data.repeat = handles.repeat;
            handles.data.waves = handles.song;
            handles.data.songNames = handles.songNames;
            handles.data.timeLabels = tLabels;

            data = handles.data;
            save(handles.savePath,'data')
            disp('Data Saved');

        elseif handles.startOrStop == 0,
            tLabels = [];
            break
        end
    end
    
    %Setup and SAVE DATA
    handles.data.booth = handles.booth;
    handles.data.nGo1 = handles.nGo1;
    handles.data.nGo2 = handles.nGo2;
    handles.data.repeat = handles.repeat;
    handles.data.waves = handles.song;
    handles.data.songNames = handles.songNames;
    handles.data.timeLabels = tLabels;
    
    data = handles.data;
    save(handles.savePath,'data')
    disp('Data Saved');
    
    handles.running = 0;
    disp('PAUSE')
end

guidata(hObject, handles);







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE FOLLOWING FUNCTIONS ARE CALLED DURING THE RUNNING OF THE MAIN CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BUILD A BLOCK OF STIMULI WITH GO, NOGO, AND CATCH TRIALS
function [stims, nGo1, nGo2, blockSize, song, songNames, bigBlockSize, reinforceSchedule] = buildBlock(hObject, eventdata, handles)
% %First, set up the block
% %Revision 2/19/09
% %Forcing "BigBlock" to be equal to handles.reinforceInterval (default=100)
% %This will consist of n blocks, where n = ceil(100/blockSize)
% %So blocks will still be made independenly (each block will still be blockSize
% %trials long), but the program will make a bunch of them at once. This will
% %make sure that we control the reinforcement rates

% Create the block of trials
[stims, nGo1, nGo2, blockSize, song, songNames, bigBlockSize, reinforceSchedule] = buildBlock_Catch_Reinforce(hObject, eventdata, handles);

% Report some numbers back to the GUI
set(handles.bigBlockDisplay,'String',num2str(bigBlockSize));
set(handles.bigBlockDisplay2,'String',num2str(bigBlockSize));
set(handles.localBlockSizeDisplay,'String',num2str(blockSize));
set(handles.nKey1SongsDisplay,'String',num2str(nGo1));
set(handles.nKey2SongsDisplay,'String',num2str(nGo2));
guidata(hObject, handles);


function [stims, nA, nB, blockSize, song, songNames, bigBlockSize, reinforceSchedule] = buildBlock_Catch_Reinforce(hObject, eventdata, handles)
%Built a block incorporating both catch trials and non-reinforced trials

nA = length(handles.ASongs);
nB = length(handles.BSongs);
blockSize = handles.repsPerBlock*(nA + nB);
nSmallBlocks = ceil(handles.reinforceInterval/blockSize);
bigBlockSize = blockSize*nSmallBlocks;

% Pick out the Go, NoGo and catch songs
songCount = 1;
for i = 1:nA,
    song{songCount} = handles.allSongs{handles.ASongs(i)};
    songNames{songCount} = handles.songList{handles.ASongs(i)};
    songCount = songCount + 1;
end
for i = 1:nB,
    song{songCount} = handles.allSongs{handles.BSongs(i)};
    songNames{songCount} = handles.songList{handles.BSongs(i)};
    songCount = songCount + 1;
end

% Deal with catch trials
%If # unique catch songs < # desired catch trials, replicate the list of
%catch songs to fulfill the # desired catch trials. If # unique catch songs
%> # desired catch trials, use a random subset of the unique catch songs.
catchVect = randperm(length(handles.CSongs));
catchVect = repmat(catchVect,1,ceil(handles.nC/length(catchVect)));
catchVect = catchVect(1:handles.nC);
for i = 1:length(handles.CSongs),
    song{songCount} = handles.allSongs{handles.CSongs(i)};
    songNames{songCount} = handles.songList{handles.CSongs(i)};
    songCount = songCount + 1;
end

% Get the randomly selected catch trials
%Next, select the trials that will be used as catch trials.
%Catch trials will replace normal Go or NoGo trials in these cases.
%Make sure they are separated by at least (bigBlockSize/nCatchTrials)/2
%trials.
if handles.nC > 0,
    meanCatchRate = round(bigBlockSize/handles.nC);
    interCatchIntervals = (meanCatchRate-round(meanCatchRate/3)):(meanCatchRate+round(meanCatchRate/3));
    for i = 1:handles.nC,
        catchIntervalInd = randperm(length(interCatchIntervals));
        catchInterval(i) = interCatchIntervals(catchIntervalInd(1));
    end
    catchLocations = cumsum(catchInterval);
    if catchLocations(end) > bigBlockSize,
        catchLocations(end) = bigBlockSize;
    end
else
    catchLocations = [];
end

% Make the list of stimuli to be used in this block.
%Insert the catch trials at the end.
stims = [];
for i = 1:nSmallBlocks,
    stimList = [];
    for i = 1:(nA+nB),
        stimList = [stimList i*ones(1,handles.repsPerBlock)];
    end
    stimOrder = randperm(blockSize);
    stims = [stims stimList(stimOrder)];
end

% Now, insert catch trials
stims(catchLocations) = nA + nB + catchVect;
%Done

% Set up reward schedules for the big block
reinforceSchedule = ones(size(stims));
AStims = find(stims<=nA);
reinforceVectorReward = [ones(1,round(length(AStims)*handles.goRate)) zeros(1,round(length(AStims)*(1-handles.goRate)))];
reinforceRandIndReward = randperm(length(reinforceVectorReward));
reinforceSchedule(AStims) = reinforceVectorReward(reinforceRandIndReward(1:length(AStims)));

BStims = intersect(find(stims>nA),find(stims<=(nA+nB)));
reinforceVectorPunish = [ones(1,round(length(BStims)*handles.nogoRate)) zeros(1,round(length(BStims)*(1-handles.nogoRate)))];
reinforceRandIndPunish = randperm(length(reinforceVectorPunish));
reinforceSchedule(BStims) = reinforceVectorPunish(reinforceRandIndPunish(1:length(BStims)));


function [handles] = ReadSettings(handles)
% Read the GUI settings prior to running the task

handles.saveName = get(handles.saveFileNameEdit,'String');
handles.saveNum = get(handles.saveFileNumberEdit,'String');
handles.saveFile = [handles.saveName,'_',handles.saveNum];
handles.savePath = [handles.saveDir,'\',handles.saveFile];

handles.verbose = get(handles.verboseCheckbox,'Value');
handles.repeat = get(handles.repeatCheckbox,'Value');

handles.volume = str2num(get(handles.volumeEdit,'String'));

% Get the timing parameters
handles.startDelay = str2num(get(handles.startDelayEdit,'String'));
handles.responseDur = str2num(get(handles.responseDurationEdit,'String'));
handles.rewardDur = str2num(get(handles.rewardDurationEdit,'String'));
handles.punishDur = str2num(get(handles.punishDurationEdit,'String'));
handles.nullDur = str2num(get(handles.nullDurationEdit,'String'));
handles.itiMin = str2num(get(handles.itiMinEdit,'String'));
handles.itiMax = str2num(get(handles.itiMaxEdit,'String'));

% Get the reward rates from the GUI
handles.goRate = str2num(get(handles.goRateEdit,'String'))/100;
handles.nogoRate = str2num(get(handles.nogoRateEdit,'String'))/100;
handles.reinforceInterval = str2num(get(handles.bigBlockEdit,'String'));

% Block and song information
handles.repsPerBlock = str2num(get(handles.repsPerBlockEdit,'String'));
handles.ASongs = get(handles.key1SongList,'Value');
handles.BSongs = get(handles.key2SongList,'Value');
handles.CSongs = get(handles.catchSongList,'Value');
handles.nC = str2num(get(handles.nCatchEdit,'String'));

%Reinforcement Associations
handles.key1HitOutcome(1) = get(handles.Reward1Button,'Value');
handles.key1HitOutcome(2) = get(handles.Punish1Button,'Value');
handles.key1HitOutcome(3) = get(handles.Null1Button,'Value');
handles.key1MissOutcome(1) = get(handles.Reward2Button,'Value');
handles.key1MissOutcome(2) = get(handles.Punish2Button,'Value');
handles.key1MissOutcome(3) = get(handles.Null2Button,'Value');
handles.key1NROutcome(1) = get(handles.Reward3Button,'Value');
handles.key1NROutcome(2) = get(handles.Punish3Button,'Value');
handles.key1NROutcome(3) = get(handles.Null3Button,'Value');
handles.key2HitOutcome(1) = get(handles.Reward4Button,'Value');
handles.key2HitOutcome(2) = get(handles.Punish4Button,'Value');
handles.key2HitOutcome(3) = get(handles.Null4Button,'Value');
handles.key2MissOutcome(1) = get(handles.Reward5Button,'Value');
handles.key2MissOutcome(2) = get(handles.Punish5Button,'Value');
handles.key2MissOutcome(3) = get(handles.Null5Button,'Value');
handles.key2NROutcome(1) = get(handles.Reward6Button,'Value');
handles.key2NROutcome(2) = get(handles.Punish6Button,'Value');
handles.key2NROutcome(3) = get(handles.Null6Button,'Value');


function [handles] = UpdateStats(handles,respCategory,reward,punish)
% Update all of the stats

%Keep track of each response category
handles.responseCount(respCategory) = handles.responseCount(respCategory) + 1;
set(handles.nKey1HitsDisplay,'String',num2str(handles.responseCount(1)));
set(handles.nKey1FAsDisplay,'String',num2str(handles.responseCount(2)));
set(handles.nKey2HitsDisplay,'String',num2str(handles.responseCount(3)));
set(handles.nKey2FAsDisplay,'String',num2str(handles.responseCount(4)));
set(handles.nNoResponseDisplay,'String',num2str(handles.responseCount(5)));

%Keep track of # of trials reinforced
if punish == 1 || reward == 1,
    handles.responseCountReinforced(respCategory) = handles.responseCountReinforced(respCategory) + 1;
    handles.data.reinforced(handles.trialNum) = 1;
end
handles.fractionReinforced = 100*(handles.responseCountReinforced./handles.responseCount);
set(handles.fractionKey1ReinforcedDisplay,'String',num2str(handles.fractionReinforced(1)));
set(handles.fractionKey2ReinforcedDisplay,'String',num2str(handles.fractionReinforced(4)));

%Keep track of # trials and blocks completed
set(handles.nTrialsDisplay,'String',num2str(handles.trialNum));
set(handles.nBlocksDisplay,'String',num2str(handles.blockNum));
handles.trialNum = handles.trialNum + 1;


function [t iti response reward punish respCategory tLabels newActive] = TAFCTrial(handles, songPick, reinforce)
% Script for the timing and monitoring of a single Go-NoGo Trial
% This is for 1 colburn booth only
% David Schneider
% 6/11/08

% Go through one iteration of the entire task
% 1) Delay
% 2) Song Presentation
% 3) Response Interval
% 4) Reward/Punishment
% 5) ITI

tcount = 0;

% "EFE"
tryflag = 1;
while tryflag,
    try
        eval(['load booth',num2str(handles.booth),'Status'])
        tryflag = 0;
    catch
        tryflag = 1;
        disp(['Error while reading booth ',num2str(handles.booth)]);
    end
end

boothStatus.led = 0; % "EFE"
boothStatus.led2 = 0; % "EFE"

% "EFE"
tryflag = 1;
while tryflag,
    try
        eval(['save booth',num2str(handles.booth),'Status boothStatus'])
        tryflag = 0;
    catch
        tryflag = 1;
        disp(['Error while writing booth ',num2str(handles.booth)]);
    end
end


%----------------------------
% Start with user-specified delay
%----------------------------

tcount = tcount + 1;
tcurrent = clock;
t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
tLabels{tcount} = 'DelayOn';
td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
if handles.verbose == 1,
    disp(['Begin Delay (hr:m:s:ms): ',displayTime])
end

pause(handles.startDelay)

tcount = tcount + 1;
tcurrent = clock;
t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
tLabels{tcount} = 'DelayOff';
td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
if handles.verbose == 1,
    disp(['End Delay (hr:m:s:ms): ',displayTime])
end


%----------------------------
% Make the song stereo, set one channel to zero
%----------------------------
handles.gain = handles.channelGain*handles.volume;
songToPlay = repmat(handles.song{songPick},1,2).*repmat(handles.gain,length(handles.song{songPick}),1);


%----------------------------
% Play the song
%----------------------------
tcount = tcount + 1;
tcurrent = clock;
t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
tLabels{tcount} = 'PlaybackOn';
td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
if handles.verbose == 1,
    disp(['Begin Sound Playback (hr:m:s:ms): ',displayTime])
end

% modified MING
p = audioplayer(songToPlay(1:end, 2),handles.fs,16,handles.speaker);
play(p)
% modified 
% 
% p = audioplayer(songToPlay,handles.fs,16,handles.speaker);
% play(p)


%----------------------------
% Monitor the response and the playback status
%----------------------------
response = 0;
isRunning = isplaying(p);
while isRunning,
    
    % Check for a key press
    tryflag = 1;
    while tryflag,
        try
            eval(['load key',num2str(handles.booth),'Status'])
            tryflag = 0;
        catch
            tryflag = 1;
            disp(['Error while reading key ',num2str(handles.booth)]);
        end
    end
    pinCheck1 = keyStatus.key1;
    pinCheck2 = keyStatus.key2;

    if pinCheck1 < 0.5, %NOTE: 8/21/08 - changed logic to normally high, look for transition to low!!
        response = 1;
        break
    elseif pinCheck2 < 0.5,
        response = 2;
        break
    end
    
    % Check for the sound playback to finish
    isRunning = isplaying(p);
end

if isRunning == 0,
    if handles.verbose == 1,
        disp('End Song')
    end
else
    if handles.verbose == 1,
        disp('Response during song playback')
    end
end


%----------------------------
% Decide whether or not to terminate song on early response
%----------------------------
handles.terminateSong = 0; %Currently hard coded not to terminate!!!
if isRunning == 1 && response > 0,
    if handles.terminateSong == 1,
        stop(p)
        disp('Terminated song early')
    end
end


%----------------------------
% If no response yet, monitor the response for user-specified amount of
% time
%----------------------------
if response == 0,
    tcurrent = clock;
    tstart = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
    tcheck = tstart;
    if handles.verbose == 1,
        disp('Begin Post-Stimulus Monitor')
    end
    while tcheck < (tstart + handles.responseDur);
        tcurrent = clock;
        tcheck = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
        
        tryflag = 1;
        while tryflag,
            try
                eval(['load key',num2str(handles.booth),'Status'])
                tryflag = 0;
            catch
                tryflag = 1;
                disp(['Error while reading key ',num2str(handles.booth)]);
            end
        end
        pinCheck1 = keyStatus.key1;
        pinCheck2 = keyStatus.key2;
        
        if pinCheck1 < 0.5, %NOTE: 8/21/08 - changed logic to normally high, look for transition to low!!
            response = 1;
            break
        elseif pinCheck2 < 0.5,
            response = 2;
            break
        end
    end
end

tcount = tcount + 1;
tcurrent = clock;
t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
tLabels{tcount} = 'EndResponseDuration';
td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
if handles.verbose == 1,
    disp(['End Monitor (hr:m:s:ms): ',displayTime]);
    disp(['Response = ',num2str(response)]);
end



%----------------------------
% Determine whether or not to reward/punish
% songPick = 1 is a GO1
% songPick = 2 is a GO2
%----------------------------
reward = -1;
punish = -1;
if songPick <= handles.nGo1,
    if response == 1,
        reward = handles.key1HitOutcome(1);
        punish = handles.key1HitOutcome(2);
        null = handles.key1HitOutcome(3);
        respCategory = 1;
    elseif response == 2
        reward = handles.key1MissOutcome(1);
        punish = handles.key1MissOutcome(2);
        null = handles.key1MissOutcome(3);
        respCategory = 2;
    else
        reward = handles.key1NROutcome(1);
        punish = handles.key1NROutcome(2);
        null = handles.key1NROutcome(3);
        respCategory = 5;
    end
elseif songPick > handles.nGo1 && songPick <= (handles.nGo1+handles.nGo2),
    if response == 1,
        reward = handles.key2MissOutcome(1);
        punish = handles.key2MissOutcome(2);
        null = handles.key2MissOutcome(3);
        respCategory = 4;
    elseif response == 2,
        reward = handles.key2HitOutcome(1);
        punish = handles.key2HitOutcome(2);
        null = handles.key2HitOutcome(3);
        respCategory = 3;
    else
        reward = handles.key2NROutcome(1);
        punish = handles.key2NROutcome(2);
        null = handles.key2NROutcome(3);
        respCategory = 5;
    end
elseif songPick > (handles.nGo1+handles.nGo2),
    if response == 1,
        reward = 0;
        punish = 0;
        null = 1;
        respCategory = 6;
    else
        reward = 0;
        punish = 0;
        null = 1;
        respCategory = 7;
    end
end


%----------------------------
% Deliver the outcome, if any
%----------------------------
tcount = tcount + 1;
tcurrent = clock;
t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
tLabels{tcount} = 'BeginOutcome';
td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
if handles.verbose == 1,
    disp(['Begin Outcome (hr:m:s:ms): ',displayTime]);
    disp(['Reward = ',num2str(reward)]);
    disp(['Punishment = ',num2str(punish)]);
end

if reward == 1 && punish == 0 && null == 0,
    tryflag = 1;
    while tryflag,
        try
            eval(['load booth',num2str(handles.booth),'Status'])
            tryflag = 0;
        catch
            tryflag = 1;
            disp(['Error while reading booth ',num2str(handles.booth)]);
        end
    end
    boothStatus.feeder = 1;
    
    tryflag = 1;
    while tryflag,
        try
            eval(['save booth',num2str(handles.booth),'Status boothStatus'])
            tryflag = 0;
        catch
            tryflag = 1;
            disp(['Error while writing booth ',num2str(handles.booth)]);
        end
    end
    
    set(handles.FeederStatusDisplay,'String','1');
    set(handles.LightsStatusDisplay,'String','1');
    
    pause(handles.rewardDur)
    
    set(handles.FeederStatusDisplay,'String','0');
    set(handles.LightsStatusDisplay,'String','1');
    
    tryflag = 1;
    while tryflag,
        try
            eval(['load booth',num2str(handles.booth),'Status'])
            tryflag = 0;
        catch
            tryflag = 1;
            disp(['Error while reading booth ',num2str(handles.booth)]);
        end
    end
    boothStatus.feeder = 0;
    
    tryflag = 1;
    while tryflag,
        try
            eval(['save booth',num2str(handles.booth),'Status boothStatus'])
            tryflag = 0;
        catch
            tryflag = 1;
            disp(['Error while writing booth ',num2str(handles.booth)]);
        end
    end

elseif reward == 0 && punish == 1 && null == 0,
    tryflag = 1;
    while tryflag,
        try
            eval(['load booth',num2str(handles.booth),'Status'])
            tryflag = 0;
        catch
            tryflag = 1;
            disp(['Error while reading booth ',num2str(handles.booth)]);
        end
    end
    boothStatus.lights = 0;
    
    tryflag = 1;
    while tryflag,
        try
            eval(['save booth',num2str(handles.booth),'Status boothStatus'])
            tryflag = 0;
        catch
            tryflag = 1;
            disp(['Error while writing booth ',num2str(handles.booth)]);
        end
    end
    
    set(handles.FeederStatusDisplay,'String','0');
    set(handles.LightsStatusDisplay,'String','0');

    pause(handles.punishDur-0.02)
    
    set(handles.FeederStatusDisplay,'String','0');
    set(handles.LightsStatusDisplay,'String','1');
    
    tryflag = 1;
    while tryflag,
        try
            eval(['load booth',num2str(handles.booth),'Status'])
            tryflag = 0;
        catch
            tryflag = 1;
            disp(['Error while reading booth ',num2str(handles.booth)]);
        end
    end
    boothStatus.lights = 1;
    
    tryflag = 1;
    while tryflag,
        try
            eval(['save booth',num2str(handles.booth),'Status boothStatus'])
            tryflag = 0;
        catch
            tryflag = 1;
            disp(['Error while writing booth ',num2str(handles.booth)]);
        end
    end
    
elseif reward == 0 && punish == 0 && null == 1,
    set(handles.FeederStatusDisplay,'String','0');
    set(handles.LightsStatusDisplay,'String','1');
    
    pause(handles.nullDur-0.02)
    
    set(handles.FeederStatusDisplay,'String','0');
    set(handles.LightsStatusDisplay,'String','1');
else
    disp('ERROR IN DELIVERING OUTCOME')
end

tcount = tcount + 1;
tcurrent = clock;
t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
tLabels{tcount} = 'EndOutcome';
td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
if handles.verbose == 1,
    disp(['End Outcome (hr:m:s:ms): ',displayTime]);
end

%Sai Basilio
pause(1);


%----------------------------
% Wait for an ITI
% Wait for the song to finish if it is not already
%----------------------------
isRunning = isplaying(p);
while isRunning
    isRunning = isplaying(p);
end

iti = GetITI(handles);

tcount = tcount + 1;
tcurrent = clock;
t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
tLabels{tcount} = 'BeginITI';
td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
if handles.verbose == 1,
    disp(['Begin ITI (hr:m:s:ms): ',displayTime]);
    disp(['ITI = ',num2str(iti)]);
end

pause(iti-0.01)

tcount = tcount + 1;
tcurrent = clock;
t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
tLabels{tcount} = 'EndITI';
td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
if handles.verbose == 1,
    disp(['End ITI: ',displayTime]);
end

%EFE
tryflag = 1;
while tryflag,
    try
        eval(['load booth',num2str(handles.booth),'Status'])
        tryflag = 0;
    catch
        tryflag = 1;
        disp(['Error while reading booth ',num2str(handles.booth)]);
    end
end

newActive = randi(2);
boothStatus.led = newActive == 1; %Sai Basilio
boothStatus.led2 = newActive == 2; %Sai Basilio

%disp(pinActive);
%disp(p
%boothStatus.led = 1; %Sai Basilio
%boothStatus.led2 = 1; %Sai Basilio


% "EFE"
tryflag = 1;
while tryflag,
    try
        eval(['save booth',num2str(handles.booth),'Status boothStatus'])
        tryflag = 0;
    catch
        tryflag = 1;
        disp(['Error while writing booth ',num2str(handles.booth)]);
    end
end

%NOTE: the PAUSE is necessary to detect GUI button transitions
%0.01 is subtracted from ITI WHILE loop to account for pause duration
pause(0.01);


function [iti] = GetITI(handles)
%ITI is selected from a flat distribution boundaries defined by
%handles.itiMin and handles.itiMax

% Exponential Distribution
% iti = min(max(handles.itiMin,exprnd(handles.itiMean)),handles.itiMax);

% Poisson Distribution
% iti = min(max(handles.itiMin,poissrnd(handles.itiMean)),handles.itiMax);

% Flat distribution:
iti = handles.itiMin + (handles.itiMax-handles.itiMin)*rand;










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE FOLLOWING FUNCTIONS ARE CALLED VIA GUI INTERACTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RESET THE ACCUMULATED DATA
function ResetDataButton_Callback(hObject, eventdata, handles)
handles.running = 0;
handles.blockNum = 1;
handles.trialNum = 1;
handles.trialNumLocal = 1;
handles.responseCount(1:5) = [0 0 0 0 0];
set(handles.nTrialsDisplay,'String',num2str(handles.trialNum));
set(handles.nBlocksDisplay,'String',num2str(handles.blockNum));
set(handles.nKey1HitsDisplay,'String',num2str(handles.responseCount(1)));
set(handles.nKey1FAsDisplay,'String',num2str(handles.responseCount(2)));
set(handles.nKey2HitsDisplay,'String',num2str(handles.responseCount(3)));
set(handles.nKey2FAsDisplay,'String',num2str(handles.responseCount(4)));
set(handles.nNoResponseDisplay,'String',num2str(handles.responseCount(5)));

handles.data.times = [];
handles.data.iti = [];
handles.data.response = [];
handles.data.outcome = [];
handles.data.currentSong = [];

if handles.reset == 0,
    handles.saveNum = num2str(str2num(handles.saveNum) + 1);
    set(handles.saveFileNumberEdit,'String',handles.saveNum);
end

handles.reset = 1;
disp('RESET DATA')

guidata(hObject, handles);


% SELECT BOOTH 1
function booth1Button_Callback(hObject, eventdata, handles)
if handles.startOrStop == 0,
    set(handles.booth1Button,'Value',1)
    set(handles.booth2Button,'Value',0)
    set(handles.booth3Button,'Value',0)
    set(handles.booth4Button,'Value',0)
    handles.booth = 1;
end
guidata(hObject, handles);


% SELECT BOOTH 2
function booth2Button_Callback(hObject, eventdata, handles)
if handles.startOrStop == 0,
    set(handles.booth1Button,'Value',0)
    set(handles.booth2Button,'Value',1)
    set(handles.booth3Button,'Value',0)
    set(handles.booth4Button,'Value',0)
    handles.booth = 2;
end
guidata(hObject, handles);


% SELECT BOOTH 3
function booth3Button_Callback(hObject, eventdata, handles)
if handles.startOrStop == 0,
    set(handles.booth1Button,'Value',0)
    set(handles.booth2Button,'Value',0)
    set(handles.booth3Button,'Value',1)
    set(handles.booth4Button,'Value',0)
    handles.booth = 3;
end
guidata(hObject, handles);

% SELECT BOOTH 4
function booth4Button_Callback(hObject, eventdata, handles)
if handles.startOrStop == 0,
    set(handles.booth1Button,'Value',0)
    set(handles.booth2Button,'Value',0)
    set(handles.booth3Button,'Value',0)
    set(handles.booth4Button,'Value',1)
    handles.booth = 4;
end
guidata(hObject, handles);


% USER SPECIFIED CHANGES TO SAVE PATH
function setSaveDirectoryButton_Callback(hObject, eventdata, handles)
handles.saveName = get(handles.saveFileNameEdit,'String');
handles.saveNum = get(handles.saveFileNumberEdit,'String');
curdir = handles.saveDir;
handles.saveDir = uigetdir(handles.saveDir);
if handles.saveDir == 0,
    handles.saveDir = curdir;
end
handles.savePath = [handles.saveDir,'\',handles.saveName,'_',handles.saveNum];
set(handles.filenameDisplay,'String',handles.savePath)
guidata(hObject, handles);


% PLOT TAFC DATA
function PlotDataButton_Callback(hObject, eventdata, handles)
PlotTAFCData(handles.saveDir,handles.saveFile);
disp('Data plotted.')


% EXPORT TAFC DATA
function ExportDataButton_Callback(hObject, eventdata, handles)
success = ExportTAFCData(handles.saveDir,handles.saveFile);
if success == 1,
    disp('Data exported to excel!');
else
    disp('ERROR in exporting data to excel!');
end


% TURN ON APPROPRIATE BOOTH
function initializeBoothButton_Callback(hObject, eventdata, handles)
handles.feederStatus = 0;
handles.lightsStatus = 1;
handles.ledStatus = 0;  %Sai Basilio
handles.ledStatus2 = 0; %Sai Basilio
[hObject, eventdata, handles] = InitializeBooth(hObject, eventdata, handles);
guidata(hObject, handles);


% CLOSE ALL BOOTHS
function closeBoothButton_Callback(hObject, eventdata, handles)
[hObject, eventdata, handles] = CloseBooth(hObject, eventdata, handles);
guidata(hObject, handles);


% VOLUME CONTROL
function volumeSlider_Callback(hObject, eventdata, handles)
handles.volume = get(hObject,'Value');
set(handles.volumeEdit,'String',num2str(round(100*handles.volume)/100))
guidata(hObject, handles);


% VOLUME CONTROL
function volumeEdit_Callback(hObject, eventdata, handles)
handles.volume = str2num(get(hObject,'String'));
set(handles.volumeSlider,'Value',handles.volume)
guidata(hObject, handles);


% SAVE THE SETTINGS FOR FUTURE USE
function saveSettingsButton_Callback(hObject, eventdata, handles)
% Get the directory and filename for saving
curDir = cd;
cd(handles.settingsDir)
[saveFile,savePath] = uiputfile('*.mat','Type the name of the saved settings:');

% Get all the save parameters
saved.startDelay = str2num(get(handles.startDelayEdit,'String'));
saved.responseDur = str2num(get(handles.responseDurationEdit,'String'));
saved.rewardDur = str2num(get(handles.rewardDurationEdit,'String'));
saved.punishDur = str2num(get(handles.punishDurationEdit,'String'));
saved.nullDur = str2num(get(handles.nullDurationEdit,'String'));
saved.itiMin = str2num(get(handles.itiMinEdit,'String'));
saved.itiMax = str2num(get(handles.itiMaxEdit,'String'));

saved.volume = str2num(get(handles.volumeEdit,'String'));

saved.verbose = get(handles.verboseCheckbox,'Value');
saved.repeat = get(handles.repeatCheckbox,'Value');

% Get the reward rates from the GUI
saved.goRate = str2num(get(handles.goRateEdit,'String'))/100;
saved.nogoRate = str2num(get(handles.nogoRateEdit,'String'))/100;
saved.reinforceInterval = str2num(get(handles.bigBlockEdit,'String'));

% Block and song information
saved.repsPerBlock = str2num(get(handles.repsPerBlockEdit,'String'));
saved.nC = str2num(get(handles.nCatchEdit,'String'));

% Reinforcement
saved.key1HitOutcome(1) = get(handles.Reward1Button,'Value');
saved.key1HitOutcome(2) = get(handles.Punish1Button,'Value');
saved.key1HitOutcome(3) = get(handles.Null1Button,'Value');
saved.key1MissOutcome(1) = get(handles.Reward2Button,'Value');
saved.key1MissOutcome(2) = get(handles.Punish2Button,'Value');
saved.key1MissOutcome(3) = get(handles.Null2Button,'Value');
saved.key1NROutcome(1) = get(handles.Reward3Button,'Value');
saved.key1NROutcome(2) = get(handles.Punish3Button,'Value');
saved.key1NROutcome(3) = get(handles.Null3Button,'Value');
saved.key2HitOutcome(1) = get(handles.Reward4Button,'Value');
saved.key2HitOutcome(2) = get(handles.Punish4Button,'Value');
saved.key2HitOutcome(3) = get(handles.Null4Button,'Value');
saved.key2MissOutcome(1) = get(handles.Reward5Button,'Value');
saved.key2MissOutcome(2) = get(handles.Punish5Button,'Value');
saved.key2MissOutcome(3) = get(handles.Null5Button,'Value');
saved.key2NROutcome(1) = get(handles.Reward6Button,'Value');
saved.key2NROutcome(2) = get(handles.Punish6Button,'Value');
saved.key2NROutcome(3) = get(handles.Null6Button,'Value');

% Save the settings
cd(savePath)
save(saveFile,'saved')
cd(curDir)
disp('Settings have been saved')


% LOAD PREVIOUSLY USED SETTINGS
function loadSettingsButton_Callback(hObject, eventdata, handles)
% Get the user-specified file
curDir = cd;
cd(handles.settingsDir)
[loadFile,loadDir] = uigetfile('*.mat','Select the settings file:');
cd(loadDir)
load(loadFile)
cd(curDir)

% Set all of the settings in the GUI
set(handles.startDelayEdit,'String',num2str(saved.startDelay));
set(handles.responseDurationEdit,'String',num2str(saved.responseDur));
set(handles.rewardDurationEdit,'String',num2str(saved.rewardDur));
set(handles.punishDurationEdit,'String',num2str(saved.punishDur));
set(handles.nullDurationEdit,'String',num2str(saved.nullDur));
set(handles.itiMinEdit,'String',num2str(saved.itiMin));
set(handles.itiMaxEdit,'String',num2str(saved.itiMax));
set(handles.goRateEdit,'String',num2str(saved.goRate*100));
set(handles.nogoRateEdit,'String',num2str(saved.nogoRate*100));
set(handles.bigBlockEdit,'String',num2str(saved.reinforceInterval));
set(handles.repsPerBlockEdit,'String',num2str(saved.repsPerBlock));
set(handles.nCatchEdit,'String',num2str(saved.nC));
set(handles.volumeEdit,'String',num2str(saved.volume));
set(handles.volumeSlider,'Value',saved.volume);
set(handles.Reward1Button,'Value',saved.key1HitOutcome(1));
set(handles.Punish1Button,'Value',saved.key1HitOutcome(2));
set(handles.Null1Button,'Value',saved.key1HitOutcome(3));
set(handles.Reward2Button,'Value',saved.key1MissOutcome(1));
set(handles.Punish2Button,'Value',saved.key1MissOutcome(2));
set(handles.Null2Button,'Value',saved.key1MissOutcome(3));
set(handles.Reward3Button,'Value',saved.key1NROutcome(1));
set(handles.Punish3Button,'Value',saved.key1NROutcome(2));
set(handles.Null3Button,'Value',saved.key1NROutcome(3));
set(handles.Reward4Button,'Value',saved.key2HitOutcome(1));
set(handles.Punish4Button,'Value',saved.key2HitOutcome(2));
set(handles.Null4Button,'Value',saved.key2HitOutcome(3));
set(handles.Reward5Button,'Value',saved.key2MissOutcome(1));
set(handles.Punish5Button,'Value',saved.key2MissOutcome(2));
set(handles.Null5Button,'Value',saved.key2MissOutcome(3));
set(handles.Reward6Button,'Value',saved.key2NROutcome(1));
set(handles.Punish6Button,'Value',saved.key2NROutcome(2));
set(handles.Null6Button,'Value',saved.key2NROutcome(3));
set(handles.verboseCheckbox,'Value',saved.verbose);
set(handles.repeatCheckbox,'Value',saved.repeat);

% Set all of the parameters
handles.startDelay = saved.startDelay;
handles.responseDur = saved.responseDur;
handles.rewardDur = saved.rewardDur;
handles.punishDur = saved.punishDur;
handles.nullDur = saved.nullDur;
handles.itiMinEdit = saved.itiMin;
handles.itiMaxEdit = saved.itiMax;
handles.goRateEdit = saved.goRate;
handles.nogoRateEdit = saved.nogoRate;
handles.reinforceInterval = saved.reinforceInterval;
handles.repsPerBlockEdit = saved.repsPerBlock;
handles.nC = saved.nC;
handles.volume = saved.volume;
handles.key1HitOutcome = saved.key1HitOutcome;
handles.key1MissOutcome = saved.key1MissOutcome;
handles.key1NROutcome = saved.key1NROutcome;
handles.key2HitOutcome = saved.key2HitOutcome;
handles.key2MissOutcome = saved.key2MissOutcome;
handles.key2NROutcome = saved.key2NROutcome;
handles.verbose = saved.verbose;
handles.repeat = saved.repeat;

disp('Settings have been loaded')


% REINFORCEMENT SCHEDULE
function Reward1Button_Callback(hObject, eventdata, handles)
set(handles.Reward1Button,'Value',1)
set(handles.Punish1Button,'Value',0)
set(handles.Null1Button,'Value',0)
handles.key1HitOutcome = [1 0 0];

function Punish1Button_Callback(hObject, eventdata, handles)
set(handles.Reward1Button,'Value',0)
set(handles.Punish1Button,'Value',1)
set(handles.Null1Button,'Value',0)
handles.key1HitOutcome = [0 1 0];

function Null1Button_Callback(hObject, eventdata, handles)
set(handles.Reward1Button,'Value',0)
set(handles.Punish1Button,'Value',0)
set(handles.Null1Button,'Value',1)
handles.key1HitOutcome = [0 0 1];


function Reward2Button_Callback(hObject, eventdata, handles)
set(handles.Reward2Button,'Value',1)
set(handles.Punish2Button,'Value',0)
set(handles.Null2Button,'Value',0)
handles.key1MissOutcome = [1 0 0];

function Punish2Button_Callback(hObject, eventdata, handles)
set(handles.Reward2Button,'Value',0)
set(handles.Punish2Button,'Value',1)
set(handles.Null2Button,'Value',0)
handles.key1MissOutcome = [0 1 0];

function Null2Button_Callback(hObject, eventdata, handles)
set(handles.Reward2Button,'Value',0)
set(handles.Punish2Button,'Value',0)
set(handles.Null2Button,'Value',1)
handles.key1MissOutcome = [0 0 1];


function Reward3Button_Callback(hObject, eventdata, handles)
set(handles.Reward3Button,'Value',1)
set(handles.Punish3Button,'Value',0)
set(handles.Null3Button,'Value',0)
handles.key1NROutcome = [1 0 0];

function Punish3Button_Callback(hObject, eventdata, handles)
set(handles.Reward3Button,'Value',0)
set(handles.Punish3Button,'Value',1)
set(handles.Null3Button,'Value',0)
handles.key1NROutcome = [0 1 0];

function Null3Button_Callback(hObject, eventdata, handles)
set(handles.Reward3Button,'Value',0)
set(handles.Punish3Button,'Value',0)
set(handles.Null3Button,'Value',1)
handles.key1NROutcome = [0 0 1];


function Reward4Button_Callback(hObject, eventdata, handles)
set(handles.Reward4Button,'Value',1)
set(handles.Punish4Button,'Value',0)
set(handles.Null4Button,'Value',0)
handles.key2HitOutcome = [1 0 0];

function Punish4Button_Callback(hObject, eventdata, handles)
set(handles.Reward4Button,'Value',0)
set(handles.Punish4Button,'Value',1)
set(handles.Null4Button,'Value',0)
handles.key2HitOutcome = [0 1 0];

function Null4Button_Callback(hObject, eventdata, handles)
set(handles.Reward4Button,'Value',0)
set(handles.Punish4Button,'Value',0)
set(handles.Null4Button,'Value',1)
handles.key2HitOutcome = [0 0 1];


function Reward5Button_Callback(hObject, eventdata, handles)
set(handles.Reward5Button,'Value',1)
set(handles.Punish5Button,'Value',0)
set(handles.Null5Button,'Value',0)
handles.key2MissOutcome = [1 0 0];

function Punish5Button_Callback(hObject, eventdata, handles)
set(handles.Reward5Button,'Value',0)
set(handles.Punish5Button,'Value',1)
set(handles.Null5Button,'Value',0)
handles.key2MissOutcome = [0 1 0];

function Null5Button_Callback(hObject, eventdata, handles)
set(handles.Reward5Button,'Value',0)
set(handles.Punish5Button,'Value',0)
set(handles.Null5Button,'Value',1)
handles.key2MissOutcome = [0 0 1];


function Reward6Button_Callback(hObject, eventdata, handles)
set(handles.Reward6Button,'Value',1)
set(handles.Punish6Button,'Value',0)
set(handles.Null6Button,'Value',0)
handles.key2NROutcome = [1 0 0];

function Punish6Button_Callback(hObject, eventdata, handles)
set(handles.Reward6Button,'Value',0)
set(handles.Punish6Button,'Value',1)
set(handles.Null6Button,'Value',0)
handles.key2NROutcome = [0 1 0];

function Null6Button_Callback(hObject, eventdata, handles)
set(handles.Reward6Button,'Value',0)
set(handles.Punish6Button,'Value',0)
set(handles.Null6Button,'Value',1)
handles.key2NROutcome = [0 0 1];














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE FOLLOWING CALLBACKS ARE NOT USED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = TAFC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function startDelayEdit_Callback(hObject, eventdata, handles)
% hObject    handle to startDelayEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startDelayEdit as text
%        str2double(get(hObject,'String')) returns contents of startDelayEdit as a double


% --- Executes during object creation, after setting all properties.
function startDelayEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startDelayEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function responseDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to responseDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of responseDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of responseDurationEdit as a double


% --- Executes during object creation, after setting all properties.
function responseDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to responseDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rewardDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rewardDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rewardDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of rewardDurationEdit as a double


% --- Executes during object creation, after setting all properties.
function rewardDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rewardDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function punishDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to punishDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of punishDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of punishDurationEdit as a double


% --- Executes during object creation, after setting all properties.
function punishDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to punishDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nullDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nullDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nullDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of nullDurationEdit as a double


% --- Executes during object creation, after setting all properties.
function nullDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nullDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function itiMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to itiMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of itiMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of itiMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function itiMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itiMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in key1SongList.
function key1SongList_Callback(hObject, eventdata, handles)
% hObject    handle to key1SongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns key1SongList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from key1SongList


% --- Executes during object creation, after setting all properties.
function key1SongList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to key1SongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in key2SongList.
function key2SongList_Callback(hObject, eventdata, handles)
% hObject    handle to key2SongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns key2SongList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from key2SongList


% --- Executes during object creation, after setting all properties.
function key2SongList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to key2SongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function repsPerBlockEdit_Callback(hObject, eventdata, handles)
% hObject    handle to repsPerBlockEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repsPerBlockEdit as text
%        str2double(get(hObject,'String')) returns contents of repsPerBlockEdit as a double


% --- Executes during object creation, after setting all properties.
function repsPerBlockEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repsPerBlockEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in verboseCheckbox.
function verboseCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to verboseCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of verboseCheckbox


% --- Executes on button press in repeatCheckbox.
function repeatCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to repeatCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of repeatCheckbox


% --- Executes on button press in IO1Checkbox.
function IO1Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO1Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO1Checkbox


% --- Executes on button press in IO3Checkbox.
function IO3Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO3Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO3Checkbox


% --- Executes on button press in IO5Checkbox.
function IO5Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO5Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO5Checkbox


% --- Executes on button press in IO7Checkbox.
function IO7Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO7Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO7Checkbox


% --- Executes on button press in IO9Checkbox.
function IO9Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO9Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO9Checkbox


% --- Executes on button press in IO11Checkbox.
function IO11Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO11Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO11Checkbox


% --- Executes on button press in IO13Checkbox.
function IO13Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO13Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO13Checkbox


% --- Executes on button press in IO15Checkbox.
function IO15Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO15Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO15Checkbox


% --- Executes on button press in IO33Checkbox.
function IO33Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO33Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO33Checkbox


% --- Executes on button press in IO35Checkbox.
function IO35Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO35Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO35Checkbox


% --- Executes on button press in IO37Checkbox.
function IO37Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO37Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO37Checkbox


% --- Executes on button press in IO39Checkbox.
function IO39Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO39Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO39Checkbox


% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18


% --- Executes on button press in IO41Checkbox.
function IO41Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO41Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO41Checkbox


% --- Executes on button press in IO43Checkbox.
function IO43Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO43Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO43Checkbox


% --- Executes on button press in IO45Checkbox.
function IO45Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO45Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO45Checkbox


% --- Executes on button press in IO47Checkbox.
function IO47Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IO47Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IO47Checkbox


% --- Executes on button press in checkbox23.
function checkbox23_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox23


% --- Executes on button press in checkbox24.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox24


% --- Executes on button press in checkbox25.
function checkbox25_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox25


% --- Executes on button press in checkbox26.
function checkbox26_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox26


% --- Executes on button press in SpeakerCh1Checkbox.
function SpeakerCh1Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to SpeakerCh1Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SpeakerCh1Checkbox


% --- Executes on button press in SpeakerCh2Checkbox.
function SpeakerCh2Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to SpeakerCh2Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SpeakerCh2Checkbox


% --- Executes on button press in SpeakerCh3Checkbox.
function SpeakerCh3Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to SpeakerCh3Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SpeakerCh3Checkbox


% --- Executes on button press in SpeakerCh4Checkbox.
function SpeakerCh4Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to SpeakerCh4Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SpeakerCh4Checkbox


function saveFileNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to saveFileNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveFileNameEdit as text
%        str2double(get(hObject,'String')) returns contents of saveFileNameEdit as a double



% --- Executes during object creation, after setting all properties.
function saveFileNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveFileNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function saveFileNumberEdit_Callback(hObject, eventdata, handles)
% hObject    handle to saveFileNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveFileNumberEdit as text
%        str2double(get(hObject,'String')) returns contents of saveFileNumberEdit as a double



% --- Executes during object creation, after setting all properties.
function saveFileNumberEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveFileNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function filenameDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenameDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in catchSongList.
function catchSongList_Callback(hObject, eventdata, handles)
% hObject    handle to catchSongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns catchSongList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from catchSongList


% --- Executes during object creation, after setting all properties.
function catchSongList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to catchSongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nCatchEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nCatchEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nCatchEdit as text
%        str2double(get(hObject,'String')) returns contents of nCatchEdit as a double


% --- Executes during object creation, after setting all properties.
function nCatchEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nCatchEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bigBlockEdit_Callback(hObject, eventdata, handles)
% hObject    handle to bigBlockEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bigBlockEdit as text
%        str2double(get(hObject,'String')) returns contents of bigBlockEdit as a double


% --- Executes during object creation, after setting all properties.
function bigBlockEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bigBlockEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function goRateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to goRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of goRateEdit as text
%        str2double(get(hObject,'String')) returns contents of goRateEdit as a double


% --- Executes during object creation, after setting all properties.
function goRateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nogoRateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nogoRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nogoRateEdit as text
%        str2double(get(hObject,'String')) returns contents of nogoRateEdit as a double


% --- Executes during object creation, after setting all properties.
function nogoRateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nogoRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function volumeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function volumeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function itiMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to itiMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of itiMinEdit as text
%        str2double(get(hObject,'String')) returns contents of itiMinEdit as a double


% --- Executes during object creation, after setting all properties.
function itiMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itiMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ADJUST THE WAVE FILE DIRECTORY
function setStimDirectoryButton_Callback(hObject, eventdata, handles)
curdir = handles.wavDir;
handles.wavDir = uigetdir(handles.wavDir);
if handles.wavDir == 0,
    handles.wavDir = curdir;
end

curDir = cd;
cd(handles.wavDir);
d = dir;
songCount = 1;
for i = 1:length(d),
    if d(i).isdir ~= 1,
        handles.songList{songCount} = d(i).name;
        [handles.allSongs{songCount} handles.fs nbits] = wavread(d(i).name);
        songCount = songCount + 1;
    end
end
cd(curDir);
songCount = songCount - 1;

% Set the song parameters in the GUI
set(handles.key1SongList,'Max',songCount);
set(handles.key2SongList,'Max',songCount);
set(handles.catchSongList,'Max',songCount);
set(handles.key1SongList,'String',handles.songList);
set(handles.key2SongList,'String',handles.songList);
set(handles.catchSongList,'String',handles.songList);

guidata(hObject, handles);


