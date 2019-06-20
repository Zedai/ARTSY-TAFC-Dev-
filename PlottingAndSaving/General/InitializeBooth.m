function [hObject, eventdata, handles] = InitializeBooth(hObject, eventdata, handles)
% Initialize one of the four booths.
%
% Copyright (c) 2010
% David M. Schneider
% Columbia University
% Department of Psychology
% July 13, 2010

%% Select the audio output device and the stereo channel
switch handles.booth,
    case 1
        handles.speaker = 3;
        handles.channelGain = [1 0];
    case 2
        handles.speaker = 3;
        handles.channelGain = [0 1];
    case 3
        handles.speaker = 2;
        handles.channelGain = [1 0];
    case 4
        handles.speaker = 2;
        handles.channelGain = [0 1];
end

%% Set all other booth specific settings
switch handles.booth
    case 1
        %Assign the appropriate value to handles.booth
        handles.booth = 1;
        
        handles.feeder = 8;
        handles.lights = 4;
        
%         handles.feederStatus = 0;
%         handles.lightsStatus = 1;
        
        %adjust the GUI I/O checkmarks
        set(handles.booth1Button,'Value',1)
        set(handles.booth2Button,'Value',0)
        set(handles.booth3Button,'Value',0)
        set(handles.booth4Button,'Value',0)
        
        set(handles.SpeakerCh1Checkbox,'Value',1)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        
        % Set the booth-specific checkmarks in the GUI
        %Inputs
        set(handles.IO1Checkbox,'Value',1) %dio.Line(24)
        set(handles.IO3Checkbox,'Value',0)
        set(handles.IO5Checkbox,'Value',0)
        set(handles.IO7Checkbox,'Value',0)
        set(handles.IO9Checkbox,'Value',1)
        set(handles.IO11Checkbox,'Value',0)
        set(handles.IO13Checkbox,'Value',0)
        set(handles.IO15Checkbox,'Value',0)
        
        %Outputs1
        % set(handles.IO17Checkbox,'Value',0)
        % set(handles.IO19Checkbox,'Value',0)
        % set(handles.IO21Checkbox,'Value',0)
        % set(handles.IO23Checkbox,'Value',0)
        % set(handles.IO25Checkbox,'Value',0)
        % set(handles.IO27Checkbox,'Value',0)
        % set(handles.IO29Checkbox,'Value',0)
        % set(handles.IO31Checkbox,'Value',0) %dio.Line(1)
        
        %Outputs2
        set(handles.IO33Checkbox,'Value',1)
        set(handles.IO35Checkbox,'Value',0)
        set(handles.IO37Checkbox,'Value',0)
        set(handles.IO39Checkbox,'Value',0)
        set(handles.IO41Checkbox,'Value',1)
        set(handles.IO43Checkbox,'Value',0)
        set(handles.IO45Checkbox,'Value',0)
        set(handles.IO47Checkbox,'Value',0)
    case 2
        %Assign the appropriate value to handles.booth
        handles.booth = 2;
        
        handles.feeder = 7;
        handles.lights = 3;
        
%         handles.feederStatus = 0;
%         handles.lightsStatus = 1;
        
        %adjust the GUI I/O checkmarks
        set(handles.booth1Button,'Value',0)
        set(handles.booth2Button,'Value',1)
        set(handles.booth3Button,'Value',0)
        set(handles.booth4Button,'Value',0)
        
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',1)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        
        % Set the booth-specific checkmarks in the GUI
        %Inputs
        set(handles.IO1Checkbox,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox,'Value',1)
        set(handles.IO5Checkbox,'Value',0)
        set(handles.IO7Checkbox,'Value',0)
        set(handles.IO9Checkbox,'Value',0)
        set(handles.IO11Checkbox,'Value',1)
        set(handles.IO13Checkbox,'Value',0)
        set(handles.IO15Checkbox,'Value',0)
        
        %Outputs1
        % set(handles.IO17Checkbox,'Value',0)
        % set(handles.IO19Checkbox,'Value',0)
        % set(handles.IO21Checkbox,'Value',0)
        % set(handles.IO23Checkbox,'Value',0)
        % set(handles.IO25Checkbox,'Value',0)
        % set(handles.IO27Checkbox,'Value',0)
        % set(handles.IO29Checkbox,'Value',0)
        % set(handles.IO31Checkbox,'Value',0) %dio.Line(1)
        
        %Outputs2
        set(handles.IO33Checkbox,'Value',0)
        set(handles.IO35Checkbox,'Value',1)
        set(handles.IO37Checkbox,'Value',0)
        set(handles.IO39Checkbox,'Value',0)
        set(handles.IO41Checkbox,'Value',0)
        set(handles.IO43Checkbox,'Value',1)
        set(handles.IO45Checkbox,'Value',0)
        set(handles.IO47Checkbox,'Value',0)
    case 3
        %Assign the appropriate value to handles.booth
        handles.booth = 3;
        
        handles.feeder = 6;
        handles.lights = 2;
        
%         handles.feederStatus = 0;
%         handles.lightsStatus = 1;
        
        %adjust the GUI I/O checkmarks
        set(handles.booth1Button,'Value',0)
        set(handles.booth2Button,'Value',0)
        set(handles.booth3Button,'Value',1)
        set(handles.booth4Button,'Value',0)
        
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',1)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        
        % Set the booth-specific checkmarks in the GUI
        %Inputs
        set(handles.IO1Checkbox,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox,'Value',0)
        set(handles.IO5Checkbox,'Value',1)
        set(handles.IO7Checkbox,'Value',0)
        set(handles.IO9Checkbox,'Value',0)
        set(handles.IO11Checkbox,'Value',0)
        set(handles.IO13Checkbox,'Value',1)
        set(handles.IO15Checkbox,'Value',0)
        
        %Outputs1
        % set(handles.IO17Checkbox,'Value',0)
        % set(handles.IO19Checkbox,'Value',0)
        % set(handles.IO21Checkbox,'Value',0)
        % set(handles.IO23Checkbox,'Value',0)
        % set(handles.IO25Checkbox,'Value',0)
        % set(handles.IO27Checkbox,'Value',0)
        % set(handles.IO29Checkbox,'Value',0)
        % set(handles.IO31Checkbox,'Value',0) %dio.Line(1)
        
        %Outputs2
        set(handles.IO33Checkbox,'Value',0)
        set(handles.IO35Checkbox,'Value',0)
        set(handles.IO37Checkbox,'Value',1)
        set(handles.IO39Checkbox,'Value',0)
        set(handles.IO41Checkbox,'Value',0)
        set(handles.IO43Checkbox,'Value',0)
        set(handles.IO45Checkbox,'Value',1)
        set(handles.IO47Checkbox,'Value',0)
    case 4
        %Assign the appropriate value to handles.booth
        handles.booth = 4;
        
        handles.feeder = 5;
        handles.lights = 1;
        
%         handles.feederStatus = 0;
%         handles.lightsStatus = 1;
        
        %adjust the GUI I/O checkmarks
        set(handles.booth1Button,'Value',0)
        set(handles.booth2Button,'Value',0)
        set(handles.booth3Button,'Value',0)
        set(handles.booth4Button,'Value',1)
        
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',1)
        
        % Set the booth-specific checkmarks in the GUI
        %Inputs
        set(handles.IO1Checkbox,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox,'Value',0)
        set(handles.IO5Checkbox,'Value',0)
        set(handles.IO7Checkbox,'Value',1)
        set(handles.IO9Checkbox,'Value',0)
        set(handles.IO11Checkbox,'Value',0)
        set(handles.IO13Checkbox,'Value',0)
        set(handles.IO15Checkbox,'Value',1)
        
        %Outputs1
        % set(handles.IO17Checkbox,'Value',0)
        % set(handles.IO19Checkbox,'Value',0)
        % set(handles.IO21Checkbox,'Value',0)
        % set(handles.IO23Checkbox,'Value',0)
        % set(handles.IO25Checkbox,'Value',0)
        % set(handles.IO27Checkbox,'Value',0)
        % set(handles.IO29Checkbox,'Value',0)
        % set(handles.IO31Checkbox,'Value',0) %dio.Line(1)
        
        %Outputs2
        set(handles.IO33Checkbox,'Value',0)
        set(handles.IO35Checkbox,'Value',0)
        set(handles.IO37Checkbox,'Value',0)
        set(handles.IO39Checkbox,'Value',1)
        set(handles.IO41Checkbox,'Value',0)
        set(handles.IO43Checkbox,'Value',0)
        set(handles.IO45Checkbox,'Value',0)
        set(handles.IO47Checkbox,'Value',1)
end

%% Save the parameters to the appropriate booth
cd(handles.boothStatusDir)

%NEW: 5/21/10
%None of the booth GUIs will communicate directly with the NI card
%Instead, a separate function will interact with the card
tryflag = 1;
while tryflag == 1,
    try
        eval(['load booth',num2str(handles.booth),'Status'])
        tryflag = 0;
    catch
        tryflag = 1;
    end
end
boothStatus.lights = handles.lightsStatus; %Light
boothStatus.feeder = handles.feederStatus; %Feeder
tryflag = 1;
while tryflag == 1,
    try
        eval(['save booth',num2str(handles.booth),'Status boothStatus'])
        tryflag = 0;
    catch
        tryflag = 1;
    end
end