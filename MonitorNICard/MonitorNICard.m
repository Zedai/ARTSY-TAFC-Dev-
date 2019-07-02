
function varargout = MonitorNICard(varargin)
% The following code controls communication with the NI card
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
    'gui_OpeningFcn', @MonitorNICard_OpeningFcn, ...
    'gui_OutputFcn',  @MonitorNICard_OutputFcn, ...
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
% SET UP COMMUNICATION WITH THE CARD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MonitorNICard_OpeningFcn(hObject, eventdata, handles, varargin)

% Set up the boothStatus directory:
handles.boothStatusDir = 'C:\Users\Admin\Documents\MATLAB\ARTSY-TAFC-Dev-\MonitorNICard';

% Configure the ports
% This device has 3 ports
% Each port has 8 channels
% Set up the ports as either input ('In') or outputs ('Out')
% Each channel on a port must go the same direction

%MATLAB to NI Translator:
%NI-Pin   handles.dio.Line(x)   USE
%1                  24          Key1
%3                  23          Key1
%5                  22          Key1
%7                  21          Key1
%9                  20          Key2
%11                 19          Key2
%13                 18          Key2
%15                 17          Key2
%17                 16          LED1
%19                 15          LED1
%21                 14          LED1
%23                 13          LED1
%25                 12          LED2
%27                 11          LED2
%29                 10          LED2
%31                 9           LED2
%33                 8           Feeder
%35                 7           Feeder
%37                 6           Feeder
%39                 5           Feeder
%41                 4           Lights
%43                 3           Lights
%45                 2           Lights
%47                 1           Lights

NI = daqhwinfo('nidaq');
%NI2 = daqhwinfo('
handles.dio = digitalio(NI.AdaptorName, [NI.InstalledBoardIds{1}]);
handles.dio2 = digitalio(NI.AdaptorName, [NI.InstalledBoardIds{2}]);

addline(handles.dio, 0:7, 0, 'Out'); %Pins 47-33
addline(handles.dio, 0:7, 1, 'Out'); %Pins 31-17
addline(handles.dio, 0:7, 2, 'In'); %Pins 15-1

addline(handles.dio2, 0:7, 0, 'Out'); %Pins 47-33
addline(handles.dio2, 0:7, 1, 'Out'); %Pins 31-17
addline(handles.dio2, 0:7, 2, 'In'); %Pins 15-1

% Set up the pins to monitor
% Booth 1:
handles.key1 = [24 23 22 21]; % Booth 1, 2, 3, 4
handles.key2 = [20 19 18 17]; % Booth 1, 2, 3, 4
handles.feeder = [8 7 6 5];
handles.lights = [4 3 2 1];
handles.led = [16 15 14 13]; % "EFE"
handles.led2 = [12 11 10 9]; %Basilio Sai


% Set the textbox
monitorStatus = 'Press to begin monitoring...';
set(handles.MonitorStatusText,'String',monitorStatus)

handles.output = hObject;
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN CODE - RUNS ON BUTTON PRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Monitor_Callback(hObject, eventdata, handles)

% Go to the correct directory
cd(handles.boothStatusDir)
pause(0.01)



% Get the initial state of all keys
for i = 1:length(handles.key1),
    key1status(i) = double(getvalue(handles.dio.Line(handles.key1(i))));
    key2status(i) = double(getvalue(handles.dio.Line(handles.key2(i))));
    %Sai
    key1status(i + 4) = double(getvalue(handles.dio2.Line(handles.key1(i))));
    key2status(i + 4) = double(getvalue(handles.dio2.Line(handles.key2(i))));
end

% Get the initial state of all booths status values
% "EFE, Sai, Basilio"
load booth1Status
feederstatus(1) = boothStatus.feeder;
lightsstatus(1) = boothStatus.lights;
boothStatus.led = 1;
boothStatus.led2 = 1;
ledstatus(1) = boothStatus.led;
led2status(1) = boothStatus.led2;
load booth2Status
feederstatus(2) = boothStatus.feeder;
lightsstatus(2) = boothStatus.lights;
boothStatus.led = 1;
boothStatus.led2 = 1;
ledstatus(2) = boothStatus.led;
led2status(2) = boothStatus.led2;
load booth3Status
feederstatus(3) = boothStatus.feeder;
lightsstatus(3) = boothStatus.lights;
boothStatus.led = 1;
boothStatus.led2 = 1;
ledstatus(3) = boothStatus.led;
led2status(3) = boothStatus.led2;
load booth4Status
feederstatus(4) = boothStatus.feeder;
lightsstatus(4) = boothStatus.lights;
boothStatus.led = 1;
boothStatus.led2 = 1;
ledstatus(4) = boothStatus.led;
led2status(4) = boothStatus.led2;
load booth5Status
feederstatus(5) = boothStatus.feeder;
lightsstatus(5) = boothStatus.lights;
boothStatus.led = 1;
boothStatus.led2 = 1;
ledstatus(5) = boothStatus.led;
led2status(5) = boothStatus.led2;
load booth6Status
feederstatus(6) = boothStatus.feeder;
lightsstatus(6) = boothStatus.lights;
boothStatus.led = 1;
boothStatus.led2 = 1;
ledstatus(6) = boothStatus.led;
led2status(6) = boothStatus.led2;
load booth7Status
feederstatus(7) = boothStatus.feeder;
lightsstatus(7) = boothStatus.lights;
boothStatus.led = 1;
boothStatus.led2 = 1;
ledstatus(7) = boothStatus.led;
led2status(7) = boothStatus.led2;
load booth8Status
feederstatus(8) = boothStatus.feeder;
lightsstatus(8) = boothStatus.lights;
boothStatus.led = 1;
boothStatus.led2 = 1;
ledstatus(8) = boothStatus.led;
led2status(8) = boothStatus.led2;


% Set the card output
for i = 1:length(handles.feeder),
    cardOut(handles.feeder(i)) = feederstatus(i);
    cardOut(handles.lights(i)) = lightsstatus(i);
    cardOut(handles.led(i)) = ledstatus(i); % "EFE"
    cardOut(handles.led2(i)) = led2status(i); % "SAI Basilio"
    
    cardOut2(handles.feeder(i)) = feederstatus(i + 4);
    cardOut2(handles.lights(i)) = lightsstatus(i + 4);
    cardOut2(handles.led(i)) = ledstatus(i + 4); % "EFE"
    cardOut2(handles.led2(i)) = led2status(i + 4); % "SAI Basilio"
end
pause(0.02)
putvalue(handles.dio.Line([1:16]),cardOut) % "EFE" Changed 8 to 16
putvalue(handles.dio2.Line([1:16]),cardOut2) % "Sai  oilisab

%putvalue(handles.dio.Line([9:16]), [1 1 1 1 1 1 1 1]); %Sai

% Get the value of the toggle switch
monitorState = get(handles.Monitor,'Value');

% Get the timer status
timerState = get(handles.timerStatus,'Value');

% Set the textbox
if monitorState == 0,
    monitorStatus = 'Press to begin monitoring...';
else
    monitorStatus = 'Actively monitoring NI cards';
end
set(handles.MonitorStatusText,'String',monitorStatus)

%------------------------------------------------------------------------
% While monitorState = 1, continue checking for key presses and updating
% light and feeder status
%------------------------------------------------------------------------
turnOn = 0;


while monitorState == 1,
    
    %-----------------------------------------------------
    % First, check and update KEY STATUS
    %-----------------------------------------------------
    % Get the current state of all keys
    for i = 1:length(handles.key1),
        key1statusb(i) = double(getvalue(handles.dio.Line(handles.key1(i))));
        pause(0.01)
        key2statusb(i) = double(getvalue(handles.dio.Line(handles.key2(i))));
        pause(0.01)
        %Sai
        key1statusb(i + 4) = double(getvalue(handles.dio2.Line(handles.key1(i))));
        pause(0.01)
        key2statusb(i + 4) = double(getvalue(handles.dio2.Line(handles.key2(i))));
        pause(0.01)
    end
    
    % Check whether any keys have changed state
    key1Change = find(key1statusb~=key1status);
    
    key2Change = find(key2statusb~=key2status);
    
    keyChange = unique([key1Change,key2Change]);
    
    % Update keyStatus if there's been a change
    if ~isempty(keyChange),
        for i = keyChange
            
            tryflag = 1;
            while tryflag,
                try
                    eval(['load key',num2str(i),'Status'])
                    tryflag = 0;
                catch
                    tryflag = 1;
                    disp(['Error while reading key ',num2str(i)]);
                end
            end
            keyStatus.key1 = key1statusb(i);
            keyStatus.key2 = key2statusb(i);
            
            tryflag = 1;
            while tryflag,
                try
                    eval(['save key',num2str(i),'Status keyStatus'])
                    tryflag = 0;
                catch
                    tryflag = 1;
                    disp(['Error while writing key ',num2str(i)]);
                end
            end
            
        end
    end
    
    
    %-----------------------------------------------------
    % Next, check and update BOOTH STATUS
    %-----------------------------------------------------
    % Get the current state of all feeders
    % Get the current state of all lights
    % "EFE" Get the current state of all leds
    for i = 1:8, %Basi
        tryflag = 1;
        while tryflag,
            try
                eval(['load booth',num2str(i),'Status'])
                tryflag = 0;
            catch
                tryflag = 1;
                disp(['Error while reading booth ',num2str(i)]);
            end
        end
        feederstatusb(i) = boothStatus.feeder;
        lightsstatusb(i) = boothStatus.lights;
        ledstatusb(i) = boothStatus.led; % "EFE"
        led2statusb(i) = boothStatus.led2; % sai and basilio
    end
    
    % Check whether any feeders have changed states
    feederChange = find(feederstatusb~=feederstatus);
    lightsChange = find(lightsstatusb~=lightsstatus);
    ledChange = find(ledstatusb~=ledstatus); % "EFE"
    led2Change = find(led2statusb~=led2status); % Basilio
    
    % Update the card output vector
    %cardOut(handles.feeder) = feederstatusb;
    %cardOut(handles.lights) = lightsstatusb;
    %cardOut(handles.led) = ledstatusb; % "EFE"
    %cardOut(handles.led2) = led2statusb; %Basilio
    
    for i = 1:length(handles.feeder),
        cardOut(handles.feeder(i)) = feederstatus(i);
        cardOut(handles.lights(i)) = lightsstatus(i);
        cardOut(handles.led(i)) = ledstatus(i); % "EFE"
        cardOut(handles.led2(i)) = led2status(i); % "SAI Basilio"
        
        cardOut2(handles.feeder(i)) = feederstatus(i + 4);
        cardOut2(handles.lights(i)) = lightsstatus(i + 4);
        cardOut2(handles.led(i)) = ledstatus(i + 4); % "EFE"
        cardOut2(handles.led2(i)) = led2status(i + 4); % "SAI Basilio"
    end
    
    % Update the card if the feeder or light status' have changed
    if ~isempty(feederChange) || ~isempty(lightsChange) || ~isempty(ledChange) || ~isempty(led2Change) , % "EFE"
        putvalue(handles.dio.Line([1:16]),cardOut) % "EFE" Changed 8 to 16
        putvalue(handles.dio2.Line([1:16]),cardOut2) % Sai
    end
    
    %-----------------------------------------------------
    % Finish up some things
    %-----------------------------------------------------
    % Update the monitor vectors
    key1status = key1statusb;
    key2status = key2statusb;
    lightsstatus = lightsstatusb;
    feederstatus = feederstatusb;
    ledstatus = ledstatusb; % "EFE"
    led2status = led2statusb; %Basilio
    
    %-----------------------------------------------------
    % If the timer is ON, checktimes and
    %-----------------------------------------------------
    if timerState == 1,
        % Get the current time
        tcurrent = clock;
        tCurrent = tcurrent(4) + tcurrent(5)/60;
        
        % Get the time at which the lights should turn on
        lightsOnHour = get(handles.lightsOnHour,'String');
        lightsOnMinute = get(handles.lightsOnMinute,'String');
        tOn = str2num(lightsOnHour) + str2num(lightsOnMinute)/60;
        
        % Get the time at which the lights should turn off
        lightsOffHour = get(handles.lightsOffHour,'String');
        lightsOffMinute = get(handles.lightsOffMinute,'String');
        tOff = str2num(lightsOffHour) + str2num(lightsOffMinute)/60;
        
        % If it is in the lights-out epoch and the timer is on:
        turnOff = 1;
        while (tCurrent<tOn || tCurrent>=tOff) && timerState == 1 && monitorState == 1,
            turnOn = 1;
            if turnOff == 1,
                disp('Entering sleep mode...')
                % Set all of the feeders and lights to zero
                %SAI
                lightsstatusb = [0 0 0 0 0 0 0 0];
                feederstatusb = [0 0 0 0 0 0 0 0];
                ledstatusb = [0 0 0 0 0 0 0 0];
                led2statusb = [0 0 0 0 0 0 0 0];
                
                % Check whether any feeders have changed states
                feederChange = find(feederstatusb~=feederstatus);
                lightsChange = find(lightsstatusb~=lightsstatus);
                ledChange = find(ledstatusb~=ledstatus);
                led2Change = find(led2statusb~=led2status);
                
                % Update the card output vector
                %Sai
                for i = 1:length(feeder),
                    cardOut(handles.feeder(i)) = feederstatus(i);
                    cardOut(handles.lights(i)) = lightsstatus(i);
                    cardOut(handles.led(i)) = ledstatus(i); % "EFE"
                    cardOut(handles.led2(i)) = led2status(i); % "SAI Basilio"
                    
                    cardOut2(handles.feeder(i)) = feederstatus(i + 4);
                    cardOut2(handles.lights(i)) = lightsstatus(i + 4);
                    cardOut2(handles.led(i)) = ledstatus(i + 4); % "EFE"
                    cardOut2(handles.led2(i)) = led2status(i + 4); % "SAI Basilio"
                end
                
                % Update the card if the feeder or light status' have changed
                if ~isempty(feederChange) || ~isempty(lightsChange) || ~isempty(ledChange) || ~isempty(led2Change) , % "EFE"
                    putvalue(handles.dio.Line([1:16]),cardOut) % "EFE" Changed 8 to 16
                    putvalue(handles.dio2.Line([1:16]),cardOut2) % Sai
                end
                
                lightsstatus = lightsstatusb;
                feederstatus = feederstatusb;
                ledstatus = ledstatusb;
                led2status = led2statusb;
                
                monitorStatus = 'Lights off...sleeping!';
                set(handles.MonitorStatusText,'String',monitorStatus)
                
                turnOff = 0;
            end
            timerState = get(handles.timerStatus,'Value');
            monitorState = get(handles.Monitor,'Value');
            
            tcurrent = clock;
            tCurrent = tcurrent(4) + tcurrent(5)/60;
            
            pause(0.1)
        end
        if turnOn == 1,
            disp('Exiting sleep mode')
            turnOn = 0;
        end
        
        % Set the textbox
        monitorState = get(hObject,'Value');
        if monitorState == 0,
            monitorStatus = 'Press to begin monitoring...';
        else
            monitorStatus = 'Actively monitoring NI card';
        end
        set(handles.MonitorStatusText,'String',monitorStatus)
        
    end
    
    % Get the state of the toggle button
    monitorState = get(hObject,'Value');
    timerState = get(handles.timerStatus,'Value');
    
end

pause (.01)  %Sai
%cardOut(handles.led) = [0 0 0 0 0 0 0 0];
%putvalue(handles.dio.Line([1:4]), [0 0 0 0]); %Ssiaia

putvalue(handles.dio.Line([9:16]), [0 0 0 0 0 0 0 0]); %Ssiaia
putvalue(handles.dio2.Line([9:16]), [0 0 0 0 0 0 0 0]); %Ssiaia

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%UNUSED FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = MonitorNICard_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% --- Executes on button press in timerStatus.
function timerStatus_Callback(hObject, eventdata, handles)
% hObject    handle to timerStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timerStatus



function lightsOnHour_Callback(hObject, eventdata, handles)
% hObject    handle to lightsOnHour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lightsOnHour as text
%        str2double(get(hObject,'String')) returns contents of lightsOnHour as a double







function lightsOnMinute_Callback(hObject, eventdata, handles)
% hObject    handle to lightsOnMinute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lightsOnMinute as text
%        str2double(get(hObject,'String')) returns contents of lightsOnMinute as a double







function lightsOffHour_Callback(hObject, eventdata, handles)
% hObject    handle to lightsOffHour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lightsOffHour as text
%        str2double(get(hObject,'String')) returns contents of lightsOffHour as a double







function lightsOffMinute_Callback(hObject, eventdata, handles)
% hObject    handle to lightsOffMinute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lightsOffMinute as text
%        str2double(get(hObject,'String')) returns contents of lightsOffMinute as a double





function lightsOnHour_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lightsOnMinute_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lightsOffHour_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lightsOffMinute_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


