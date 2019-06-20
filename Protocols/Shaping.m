function varargout = Shaping(varargin)
% The following code controls the Shaping task.
%
% Copyright (c) 2010
% David M. Schneider
% Columbia University
% Department of Psychology
% July 13, 2010

% Efe Edit Version 1 (12/20/2017)
% To fix the keyStatus error


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN MATLAB INITIALIZATION (DO NOT EDIT!)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Shaping_OpeningFcn, ...
    'gui_OutputFcn',  @Shaping_OutputFcn, ...
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
function Shaping_OpeningFcn(hObject, eventdata, handles, varargin)
% Set up the default parameters for the program

protocol = 'Shaping';

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
    
    % Wait for the bird to initiate a trial
    while handles.startOrStop == 1,
        
        % On the first pass through the while loop, display status
        if StartWaiting == 1,
            disp('Waiting for initiation...')
            set(handles.statusDisplay,'String','Waiting for initiation...')
            StartWaiting = 0;
        end
        
        % Check for trial initiation
        % eval(['load key',num2str(handles.booth),'Status'])
        % pinCheck = keyStatus.key1;
        
        % "EFE"
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
        % pinCheck = keyStatus.key1;
        
        
        pause(0.01)
        handles.startOrStop = get(hObject,'Value');
        pause(0.01)
        
        % "EFE"
        try
            pinCheck = keyStatus.key1;
        catch
            disp('keyStatus.key1 doesn''t exist');
            keyStatus.key1 = 0;
            keyStatus.key2 = 1;
            pinCheck = keyStatus.key1;
        end
        
        
        % If the bird pecked a key, run the trial
        if pinCheck < 0.5 && handles.startOrStop == 1,
            
            if handles.verbose == 1,
                disp(' ');
                disp(['BEGIN TRIAL ',num2str(handles.trialNum)]);
            end
            set(handles.statusDisplay,'String','Trial running...')
            
            
            
            % RUN THROUGH A SINGLE TRIAL
            [t response reward punish respCategory tLabels] = ShapingTrial(handles);
            
            %Keep track of timing information
            handles.data.times{handles.trialNum} = t;
            handles.data.response{handles.trialNum} = response;
            handles.data.outcome{handles.trialNum} = [reward punish];
            
            handles = UpdateStats(handles,respCategory);
            
            StartWaiting = 1;
            pause(0.01); %Necessary to reload the trial #
            
            % "EFE"
            handles.data.booth = handles.booth;
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

function [handles] = ReadSettings(handles)
% Read the GUI settings prior to running the task

handles.saveName = get(handles.saveFileNameEdit,'String');
handles.saveNum = get(handles.saveFileNumberEdit,'String');
handles.saveFile = [handles.saveName,'_',handles.saveNum];
handles.savePath = [handles.saveDir,'\',handles.saveFile];

handles.verbose = get(handles.verboseCheckbox,'Value');

% Get the timing parameters
handles.startDelay = str2num(get(handles.startDelayEdit,'String'));
handles.rewardDur = str2num(get(handles.rewardDurationEdit,'String'));
handles.itiMin = str2num(get(handles.itiMinEdit,'String'));
handles.itiMax = str2num(get(handles.itiMaxEdit,'String'));


function [handles] = UpdateStats(handles,respCategory,reward,punish)
% Update all of the stats

%Keep track of # trials and blocks completed
set(handles.nTrialsDisplay,'String',num2str(handles.trialNum));
handles.trialNum = handles.trialNum + 1;


% RUN A SINGLE TRIAL
function [t response reward punish respCategory tLabels] = ShapingTrial(handles)
% Script for running a single Shaping trial

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
% ALWAYS REWARD, THIS IS JUST SHAPING
%----------------------------
respCategory = 1;
reward = 1;
punish = 0;
response = 0;


%----------------------------
% Deliver the reward
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

tcount = tcount + 1;
tcurrent = clock;
t(tcount) = tcurrent(4)*60*60 + tcurrent(5)*60 + tcurrent(6);
tLabels{tcount} = 'EndOutcome';
td = [round(tcurrent(4:6)) round(1000*(tcurrent(6) - floor(tcurrent(6))))];
displayTime = [num2str(td(1)),':',num2str(td(2)),':',num2str(td(3)),':',num2str(td(4))];
if handles.verbose == 1,
    disp(['End Outcome (hr:m:s:ms): ',displayTime]);
end

pause(0.01);


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
handles.trialNum = 1;
set(handles.nTrialsDisplay,'String',num2str(handles.trialNum));

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
handles.ledStatus = 0; % "EFE"
[hObject, eventdata, handles] = InitializeBooth(hObject, eventdata, handles);
guidata(hObject, handles);


% CLOSE ALL BOOTHS
function closeBoothButton_Callback(hObject, eventdata, handles)
[hObject, eventdata, handles] = CloseBooth(hObject, eventdata, handles);
guidata(hObject, handles);


% SAVE THE SETTINGS FOR FUTURE USE
function saveSettingsButton_Callback(hObject, eventdata, handles)
% Get the directory and filename for saving
curDir = cd;
cd(handles.settingsDir)
[saveFile,savePath] = uiputfile('*.mat','Type the name of the saved settings:');

% Get all the save parameters
saved.startDelay = str2num(get(handles.startDelayEdit,'String'));
saved.rewardDur = str2num(get(handles.rewardDurationEdit,'String'));
saved.itiMin = str2num(get(handles.itiMinEdit,'String'));
saved.itiMax = str2num(get(handles.itiMaxEdit,'String'));
saved.verbose = get(handles.verboseCheckbox,'Value');


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
set(handles.rewardDurationEdit,'String',num2str(saved.rewardDur));
set(handles.itiMinEdit,'String',num2str(saved.itiMin));
set(handles.itiMaxEdit,'String',num2str(saved.itiMax));
set(handles.verboseCheckbox,'Value',saved.verbose);

% Set all of the parameters
handles.startDelay = saved.startDelay;
handles.rewardDur = saved.rewardDur;
handles.itiMinEdit = saved.itiMin;
handles.itiMaxEdit = saved.itiMax;
handles.verbose = saved.verbose;

disp('Settings have been loaded')















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE FOLLOWING CALLBACKS ARE NOT USED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = Shaping_OutputFcn(hObject, eventdata, handles)
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


function stimOutcomeDelayEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stimOutcomeDelayEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stimOutcomeDelayEdit as text
%        str2double(get(hObject,'String')) returns contents of stimOutcomeDelayEdit as a double


% --- Executes during object creation, after setting all properties.
function stimOutcomeDelayEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimOutcomeDelayEdit (see GCBO)
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


% --- Executes on selection change in goSongList.
function goSongList_Callback(hObject, eventdata, handles)
% hObject    handle to goSongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns goSongList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from goSongList


% --- Executes during object creation, after setting all properties.
function goSongList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goSongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in noGoSongList.
function noGoSongList_Callback(hObject, eventdata, handles)
% hObject    handle to noGoSongList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns noGoSongList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from noGoSongList


% --- Executes during object creation, after setting all properties.
function noGoSongList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noGoSongList (see GCBO)
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
