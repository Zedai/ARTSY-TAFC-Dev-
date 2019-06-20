function varargout = Yoking(varargin)
% The following code controls the Go NoGo task.
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
                   'gui_OpeningFcn', @Yoking_OpeningFcn, ...
                   'gui_OutputFcn',  @Yoking_OutputFcn, ...
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
function Yoking_OpeningFcn(hObject, eventdata, handles, varargin)
% Set up the default parameters for the program

protocol = 'Yoking';

% Initialize the protocol
[hObject, eventdata, handles] = InitializeProtocol(protocol,hObject, eventdata, handles);

% Go to the booth status directory
cd(handles.boothStatusDir)

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
    
    % Wait for the bird to initiate a trial
    while handles.startOrStop == 1 && handles.trialNum<handles.nTotalTrials,
        
        % Check for whether the program has been paused
        pause(0.01)
        handles.startOrStop = get(hObject,'Value');
        pause(0.01)

        % If the bird pecked a key, run the trial
        if handles.startOrStop == 1,
            
            % Get the file name that should ACTUALLY BE PLAYED
            currSong = handles.originalData.currentSongName{handles.trialNum};
            for i = 1:length(handles.yokedPairs),
                if currSong(1) == handles.yokedPairs{i}{1};
                    yokeSong = [handles.yokedPairs{i}{2} currSong(2:end)];
                end
            end
            
            % Get this wave file
            for i = 1:length(handles.songList)
                if length(handles.songList{i})==length(yokeSong),
                    if all(handles.songList{i}==yokeSong),
                        songToPlay = handles.allSongs{i};
                    end
                end
            end
            
            iti = handles.originalData.isi(handles.trialNum);
            if handles.verbose == 1,
                disp(' ');
                disp(['BEGIN TRIAL ',num2str(handles.trialNum)]);
                disp(['Stimulus #:  ',yokeSong]);
            end
            set(handles.statusDisplay,'String','Trial running...')

            % RUN THROUGH A SINGLE TRIAL
            YokingTrial(handles, songToPlay, iti);
  
            %Keep track of how many trials in each category
            handles = UpdateStats(handles);

            pause(0.01); %Necessary to reload the trial #
        elseif handles.startOrStop == 0,
            tLabels = [];
            break
        end
    end
    
    handles.running = 0;
    disp('PAUSE')
end

guidata(hObject, handles);







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE FOLLOWING FUNCTIONS ARE CALLED DURING THE RUNNING OF THE MAIN CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = ReadSettings(handles)
% Read the GUI settings prior to running the task

handles.verbose = get(handles.verboseCheckbox,'Value');
handles.volume = str2num(get(handles.volumeEdit,'String'));

% Block and song information
handles.ASongs = get(handles.trainedSongList,'Value');
handles.BSongs = get(handles.yokedSongList,'Value');


function [handles] = UpdateStats(handles,respCategory,reward,punish)
% Update all of the stats

%Keep track of # trials and blocks completed
handles.trialNum = handles.trialNum + 1;
set(handles.nTrialsDisplay,'String',num2str(handles.trialNum));


function YokingTrial(handles, songToPlay, iti)
% Script for the timing and monitoring of a single Go-NoGo Trial
% This is for 1 colburn booth only
% David Schneider
% 6/11/08

tcount = 0;

%----------------------------
% Make the song stereo, set one channel to zero
%----------------------------
handles.gain = handles.channelGain*handles.volume;
songToPlay = repmat(songToPlay,1,2).*repmat(handles.gain,length(songToPlay),1);


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
p = audioplayer(songToPlay,handles.fs,16,handles.speaker);
play(p)

%----------------------------
% Monitor the song duration
%----------------------------
response = 0;
isRunning = isplaying(p);
while isRunning,
    isRunning = isplaying(p);
    pause(0.01)
end

if handles.verbose == 1,
    disp('End Song')
end




%----------------------------
% Wait for an ITI
% Wait for the song to finish if it is not already
%----------------------------
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







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE FOLLOWING FUNCTIONS ARE CALLED VIA GUI INTERACTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


% PLOT Yoking DATA
function PlotDataButton_Callback(hObject, eventdata, handles)
PlotTAFCData(handles.saveDir,handles.saveFile);
disp('Data plotted.')


% EXPORT Yoking DATA
function ExportDataButton_Callback(hObject, eventdata, handles)
success = ExportGoNoGoData(handles.saveDir,handles.saveFile);
if success == 1,
    disp('Data exported to excel!');
else
    disp('ERROR in exporting data to excel!');
end


% TURN ON APPROPRIATE BOOTH
function initializeBoothButton_Callback(hObject, eventdata, handles)
handles.feederStatus = 0;
handles.lightsStatus = 0;
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

for i = 1:length(handles.songList),
    handles.yokeList{i} = handles.songList{i}(1);
end
handles.yokeList = unique(handles.yokeList);
yokeCount = length(handles.yokeList);

% Set the song parameters in the GUI
% set(handles.trainedSongList,'Max',0);
set(handles.yokedSongList,'Max',yokeCount);
set(handles.pairsList,'Max',0);
% set(handles.trainedSongList,'String',[]);
set(handles.yokedSongList,'String',handles.yokeList);
set(handles.pairsList,'String',[]);
handles.yokedPairs = [];
handles.pairDisplay = [];

guidata(hObject, handles);



% LOAD THE DATA FILE WE WANT TO EMULATE
function loadFileButton_Callback(hObject, eventdata, handles)
dataDir = 'C:\Program Files\MATLAB\R2008b\work\BATTS\Data';
currDir = cd;
cd(dataDir)
[dataFile dataPath] = uigetfile('*.mat','Select data file to emulate...');
cd(dataPath)
load(dataFile);
cd(currDir)

handles.originalData = data;

% Get the inter-song intervals
for i = 1:length(handles.originalData.times)
    songTime(i) = handles.originalData.times{i}(3);
end
handles.originalData.isi = [diff(songTime)];


handles.loadedFile = ['Emulating ',dataFile];
set(handles.filenameDisplay,'String',handles.loadedFile);
handles.nTotalTrials = length(handles.originalData.currentSongName);
set(handles.nTotalTrialsDisplay,'String',num2str(handles.nTotalTrials));

% Get the list of trained songs
for i = 1:length(handles.originalData.songNames),
    handles.trainedList{i} = handles.originalData.songNames{i}(1);
end
handles.trainedList = unique(handles.trainedList);
trainedCount = length(handles.trainedList);

set(handles.trainedSongList,'Max',trainedCount);
set(handles.pairsList,'Max',0);
set(handles.trainedSongList,'String',handles.trainedList);
set(handles.pairsList,'String',[]);
handles.yokedPairs = [];
handles.pairDisplay = [];

guidata(hObject, handles);



% YOKE A SONG TO A TRAINED SONG
function addPair_Callback(hObject, eventdata, handles)

% Get the selected TRAINED and YOKED songs
trainedSong = get(handles.trainedSongList,'Value');
yokedSong = get(handles.yokedSongList,'Value');

% Make sure there aren't too many selected
if length(trainedSong)>1 || length(yokedSong)>1,
    disp('Please select ONLY ONE SONG per group!')
end

% Make sure there aren't too few selected
if isempty(trainedSong) || isempty(yokedSong),
    disp('Please select ONE SONG per group!')
end

% If one song per category selected, yoke these stims
if length(trainedSong)==1 && length(yokedSong)==1,
    nPairs = length(handles.yokedPairs);
    handles.yokedPairs{nPairs+1}{1} = handles.trainedList{trainedSong};
    handles.yokedPairs{nPairs+1}{2} = handles.yokeList{yokedSong};
    handles.pairDisplay{nPairs+1} = [handles.yokedPairs{nPairs+1}{1},'->',handles.yokedPairs{nPairs+1}{2}];
end

set(handles.pairsList,'Max',length(handles.pairDisplay));
set(handles.pairsList,'String',handles.pairDisplay);

guidata(hObject, handles);




% REMOVE ONE OF THE YOKING PAIRS
function removePair_Callback(hObject, eventdata, handles)

disp('This currently is not working')











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE FOLLOWING CALLBACKS ARE NOT USED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = Yoking_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on selection change in trainedSongList.
function trainedSongList_Callback(hObject, eventdata, handles)
% hObject    handle to trainedSongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns trainedSongList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trainedSongList


% --- Executes during object creation, after setting all properties.
function trainedSongList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trainedSongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in yokedSongList.
function yokedSongList_Callback(hObject, eventdata, handles)
% hObject    handle to yokedSongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns yokedSongList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from yokedSongList


% --- Executes during object creation, after setting all properties.
function yokedSongList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yokedSongList (see GCBO)
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


% --- Executes on selection change in pairsList.
function pairsList_Callback(hObject, eventdata, handles)
% hObject    handle to pairsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pairsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pairsList


% --- Executes during object creation, after setting all properties.
function pairsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pairsList (see GCBO)
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



function preResponseDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to preResponseDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of preResponseDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of preResponseDurationEdit as a double


% --- Executes during object creation, after setting all properties.
function preResponseDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preResponseDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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





