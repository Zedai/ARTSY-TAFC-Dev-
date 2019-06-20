function varargout = Preference(varargin)
% The following code controls the Preference task.
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
    'gui_OpeningFcn', @Preference_OpeningFcn, ...
    'gui_OutputFcn',  @Preference_OutputFcn, ...
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
function Preference_OpeningFcn(hObject, eventdata, handles, varargin)
% Set up the default parameters for the program

protocol = 'Preference';

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
    [handles.stims, handles.nGo1, handles.nGo2, handles.blockSize, handles.song, handles.songNames]...
        = buildBlock(hObject, eventdata, handles);
    
    % Wait for the bird to initiate a trial
    while handles.startOrStop == 1,
        
        % On the first pass through the while loop, display status
        % Bird must stay on perch for minimum duration
        if StartWaiting == 1,
            disp('Waiting for initiation...')
            set(handles.statusDisplay,'String','Waiting for initiation...')
            StartWaiting = 0;
            falseStart = 0;
            tcurrent = clock;tbeginWait = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
        end
        
        % Check for trial initiation
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
        pinCheck = and(pinCheck1,pinCheck2);
        
        pause(0.01)
        handles.startOrStop = get(hObject,'Value');
        pause(0.01)
        
        % If the bird pecked a key, run the trial
        if pinCheck < 0.5 && handles.startOrStop == 1,
            
            %%%%%
            % Enter if the bird initiated a trial
            %%%%%
            %Make sure the wasn't already on the perch
            tcurrent = clock;tstart = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
            if falseStart == 0 && tstart > (tbeginWait + 0.1)
                %%%%%
                %Make sure the bird stays on for N seconds
                %%%%%
                tcurrent = clock;tstart = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
                tcheck = tstart;
                birdMove = 0;
                while tcheck < (tstart + handles.perchDur),
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
                    pinCheck = and(pinCheck1,pinCheck2);
                    pause(0.01)
                    handles.startOrStop = get(hObject,'Value');
                    pause(0.01)
                    if pinCheck > 0.5,
                        birdMove = 1;
                        break
                    else
                        birdMove = 0;
                    end
                    tcurrent = clock;tcheck = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
                end
            else
                birdMove = 1;
                falseStart = 1;
            end
            
            %%%%%
            %If so, continue. If not, break.
            %%%%%
            if birdMove ~= 0,
                if falseStart == 0,
                    disp('Bird moved too early')
                end
            else
                
                % Determine which perch the bird is on
                if pinCheck1 < 0.5,
                    respCategory = 1;
                elseif pinCheck2 < 0.5,
                    respCategory = 2;
                end
                
                songPick = handles.stims(handles.trialNumLocal,respCategory);
                if handles.verbose == 1,
                    disp(' ');
                    disp(['BEGIN TRIAL ',num2str(handles.trialNum)]);
                    disp(['Stimulus #:  ',num2str(songPick)]);
                end
                set(handles.statusDisplay,'String','Trial running...')
                
                % RUN THROUGH A SINGLE TRIAL
                [t iti tLabels handles] = PreferenceTrial(handles, songPick);
                
                handles.trialNum = handles.trialNum+1;
                handles.trialNumLocal = handles.trialNumLocal+1;
                
                %Keep track of timing information
                handles.data.times{handles.trialNum} = t;
                handles.data.iti{handles.trialNum} = iti;
                handles.data.currentSong{handles.trialNum} = songPick;
                handles.data.currentSongName{handles.trialNum} = handles.songNames{songPick};
                
                handles = UpdateStats(handles,respCategory);
                
                %Build a new block if we went all the way through the previous
                %block
                if handles.trialNumLocal > handles.blockSize,
                    %Build a new block
                    [handles.stims, handles.nGo1, handles.nGo2, handles.blockSize, handles.song, handles.songNames] = buildBlock(hObject, eventdata, handles);
                    handles.trialNumLocal = 1;
                    handles.blockNum = handles.blockNum + 1;
                end
                StartWaiting = 1;
                pause(0.01); %Necessary to reload the trial #
            end
        elseif pinCheck > 0.5,
            tLabels = [];
            falseStart = 0;
        elseif handles.startOrStop == 0,
            tLabels = [];
            break
        end
    end
    
    %Setup and SAVE DATA
    handles.data.booth = handles.booth;
    handles.data.nGo1 = handles.nGo1;
    handles.data.nGo2 = handles.nGo2;
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
function [stims, nGo1, nGo2, blockSize, song, songNames] = buildBlock(hObject, eventdata, handles)

nGo1 = length(handles.ASongs);
nGo2 = length(handles.BSongs);
blockSize = handles.repsPerBlock*min(nGo1,nGo2);

songCount = 1;
for i = 1:nGo1,
    song{songCount} = handles.allSongs{handles.ASongs(i)};
    songNames{songCount} = handles.songList{handles.ASongs(i)};
    songCount = songCount + 1;
end
for i = 1:nGo2,
    song{songCount} = handles.allSongs{handles.BSongs(i)};
    songNames{songCount} = handles.songList{handles.BSongs(i)};
    songCount = songCount + 1;
end

stimList = nan*zeros(handles.repsPerBlock*max(nGo1,nGo2),2);
for i = 1:nGo1,
    stimList((handles.repsPerBlock*(i-1)+1):handles.repsPerBlock*i,1) = i*ones(handles.repsPerBlock,1);
end
for i = 1:nGo2,
    stimList((handles.repsPerBlock*(i-1)+1):handles.repsPerBlock*i,2) = (nGo1 + i)*ones(handles.repsPerBlock,1);
end
stimOrder = randperm(blockSize);
stims(:,1) = stimList(stimOrder,1);
stimOrder = randperm(blockSize);
stims(:,2) = stimList(stimOrder,2);

set(handles.localBlockSizeDisplay,'String',num2str(blockSize));
set(handles.nKey1SongsDisplay,'String',num2str(nGo1));
set(handles.nKey1SongsDisplay,'String',num2str(nGo2));


function [handles] = ReadSettings(handles)
% Read the GUI settings prior to running the task

handles.saveName = get(handles.saveFileNameEdit,'String');
handles.saveNum = get(handles.saveFileNumberEdit,'String');
handles.saveFile = [handles.saveName,'_',handles.saveNum];
handles.savePath = [handles.saveDir,'\',handles.saveFile];

handles.verbose = get(handles.verboseCheckbox,'Value');

handles.volume = str2num(get(handles.volumeEdit,'String'));

% Get the timing parameters
handles.startDelay = str2num(get(handles.startDelayEdit,'String'));
handles.perchDur = str2num(get(handles.perchDurationEdit,'String'));
handles.itiMin = str2num(get(handles.itiMinEdit,'String'));
handles.itiMax = str2num(get(handles.itiMaxEdit,'String'));

% Get the reward rates from the GUI
handles.playProb = str2num(get(handles.playProbEdit,'String'))/100;

% Block and song information
handles.repsPerBlock = str2num(get(handles.repsPerBlockEdit,'String'));
handles.ASongs = get(handles.key1SongList,'Value');
handles.BSongs = get(handles.key2SongList,'Value');


function [handles] = UpdateStats(handles,respCategory,reward,punish)
% Update all of the stats

%Keep track of each response category
handles.responseCount(respCategory) = handles.responseCount(respCategory) + 1;
set(handles.nKey1HitsDisplay,'String',num2str(handles.responseCount(1)));
set(handles.nKey2HitsDisplay,'String',num2str(handles.responseCount(2)));

%Keep track of number of trials that triggered playback
if handles.songPlayed == 1,
    handles.trialNumReinforced(respCategory) = handles.trialNumReinforced(respCategory)+1;
end
set(handles.nKey1Playbacks,'String',num2str(handles.trialNumReinforced(1)));
set(handles.nKey2Playbacks,'String',num2str(handles.trialNumReinforced(2)));


%Keep track of # trials and blocks completed
set(handles.nTrialsDisplay,'String',num2str(handles.trialNum));
set(handles.nBlocksDisplay,'String',num2str(handles.blockNum));
handles.trialNum = handles.trialNum + 1;


function [t iti tLabels handles] = PreferenceTrial(handles, songPick)
% Script for the timing and monitoring of a single PreferenceTest Trial
% This is for 1 colburn booth only
% David Schneider
% 6/11/08

% Go through one iteration of the entire task
% 1) Delay
% 2) Song Presentation
% 5) ITI

tcount = 0;

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
%Decide whether or not to play a song based on playback probability
%----------------------------
rand('twister',sum(100*clock));
toplay = rand;
if toplay <= handles.playProb,
    handles.songPlayed = 1;
else
    handles.songPlayed = 0;
end


%----------------------------
% Play the song
%----------------------------
if handles.songPlayed == 1,
    tcount = tcount + 1;
    tcurrent = clock;
    t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
    tLabels{tcount} = 'PlaybackOn';
    td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
    displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
    if handles.verbose == 1,
        disp(['Begin Sound Playback (hr:m:s:ms): ',displayTime])
    end
    p = audioplayer(songToPlay,handles.fs,16,handles.speaker);
    play(p)
else
    disp(['Did not play song; rand = ',num2str(toplay)]);
end


%----------------------------
% Wait for song to finish playing
%----------------------------
isRunning = isplaying(p);
while isRunning
    isRunning = isplaying(p);
end


%----------------------------
% Wait for an ITI
% Wait for the song to finish if it is not already
%----------------------------
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
handles.responseCount(1:2) = [0 0];
handles.trialNumReinforced(1:2) = [0 0];
set(handles.nTrialsDisplay,'String',num2str(handles.trialNum));
set(handles.nBlocksDisplay,'String',num2str(handles.blockNum));
set(handles.nKey1HitsDisplay,'String',num2str(handles.responseCount(1)));
set(handles.nKey2HitsDisplay,'String',num2str(handles.responseCount(2)));
set(handles.nKey1Playbacks,'String',num2str(handles.trialNumReinforced(1)));
set(handles.nKey2Playbacks,'String',num2str(handles.trialNumReinforced(2)));

handles.data.times = [];
handles.data.iti = [];
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


% TURN ON APPROPRIATE BOOTH
function initializeBoothButton_Callback(hObject, eventdata, handles)
handles.feederStatus = 0;
handles.lightsStatus = 1;
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
saved.perchDur = str2num(get(handles.perchDurationEdit,'String'));
saved.itiMin = str2num(get(handles.itiMinEdit,'String'));
saved.itiMax = str2num(get(handles.itiMaxEdit,'String'));

saved.volume = str2num(get(handles.volumeEdit,'String'));

saved.verbose = get(handles.verboseCheckbox,'Value');

% Get the reward rates from the GUI
saved.playProb = str2num(get(handles.playProbEdit,'String'))/100;

% Block and song information
saved.repsPerBlock = str2num(get(handles.repsPerBlockEdit,'String'));

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
set(handles.perchDurationEdit,'String',num2str(saved.perchDur));
set(handles.itiMinEdit,'String',num2str(saved.itiMin));
set(handles.itiMaxEdit,'String',num2str(saved.itiMax));
set(handles.playProbEdit,'String',num2str(saved.playProb*100));
set(handles.repsPerBlockEdit,'String',num2str(saved.repsPerBlock));
set(handles.volumeEdit,'String',num2str(saved.volume));
set(handles.volumeSlider,'Value',saved.volume);
set(handles.verboseCheckbox,'Value',saved.verbose);

% Set all of the parameters
handles.startDelay = saved.startDelay;
handles.perchDur = saved.perchDur;
handles.itiMinEdit = saved.itiMin;
handles.itiMaxEdit = saved.itiMax;
handles.playProbEdit = saved.playProb;
handles.repsPerBlockEdit = saved.repsPerBlock;
handles.volume = saved.volume;
handles.verbose = saved.verbose;

disp('Settings have been loaded')
















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE FOLLOWING CALLBACKS ARE NOT USED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = Preference_OutputFcn(hObject, eventdata, handles)
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


function perchDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to perchDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of perchDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of perchDurationEdit as a double


% --- Executes during object creation, after setting all properties.
function perchDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to perchDurationEdit (see GCBO)
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



function playProbEdit_Callback(hObject, eventdata, handles)
% hObject    handle to playProbEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playProbEdit as text
%        str2double(get(hObject,'String')) returns contents of playProbEdit as a double


% --- Executes during object creation, after setting all properties.
function playProbEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playProbEdit (see GCBO)
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
set(handles.goSongList,'Max',songCount);
set(handles.noGoSongList,'Max',songCount);
set(handles.catchSongList,'Max',songCount);
set(handles.goSongList,'String',handles.songList);
set(handles.noGoSongList,'String',handles.songList);
set(handles.catchSongList,'String',handles.songList);

guidata(hObject, handles);



