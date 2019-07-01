function [hObject, eventdata, handles] = InitializeBooth(hObject, eventdata, handles)
% Initialize one of the four booths.
%
% Copyright (c) 2010
% David M. Schneider
% Columbia University
% Department of Psychology
% July 13, 2010


%% Set all other booth specific settings

%Sai: To be completely honest, i have no idea why lightsStatus turns on
%with 0 now but thats what it is so we're rolling with it
handles.feederStatus = 0;
handles.lightsStatus = 0;

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
        
        % BASILIO
        set(handles.booth5Button,'Value',0)
        set(handles.booth6Button,'Value',0)
        set(handles.booth7Button,'Value',0)
        set(handles.booth8Button,'Value',0)
        %
        set(handles.SpeakerCh1Checkbox,'Value',1)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        %Bsilio Sai
        set(handles.SpeakerCh5Checkbox,'Value',0)
        set(handles.SpeakerCh6Checkbox,'Value',0)
        set(handles.SpeakerCh7Checkbox,'Value',0)
        set(handles.SpeakerCh8Checkbox,'Value',0)
        
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
        
        %Basilio and Sai changed this part, we believe this is the correct
        %course of a-action even though Sai does not know much about Matlab
        set(handles.IO1Checkbox2,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox2,'Value',0)
        set(handles.IO5Checkbox2,'Value',0)
        set(handles.IO7Checkbox2,'Value',0)
        set(handles.IO9Checkbox2,'Value',0)
        set(handles.IO11Checkbox2,'Value',0)
        set(handles.IO13Checkbox2,'Value',0)
        set(handles.IO15Checkbox2,'Value',0)
        
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
        %baSAI
        set(handles.IO33Checkbox2,'Value',0)
        set(handles.IO35Checkbox2,'Value',0)
        set(handles.IO37Checkbox2,'Value',0)
        set(handles.IO39Checkbox2,'Value',0)
        set(handles.IO41Checkbox2,'Value',0)
        set(handles.IO43Checkbox2,'Value',0)
        set(handles.IO45Checkbox2,'Value',0)
        set(handles.IO47Checkbox2,'Value',0)
        
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
        %baboolio
        set(handles.booth5Button,'Value',0)
        set(handles.booth6Button,'Value',0)
        set(handles.booth7Button,'Value',0)
        set(handles.booth8Button,'Value',0)
        
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',1)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        %baboolian
        set(handles.SpeakerCh5Checkbox,'Value',0)
        set(handles.SpeakerCh6Checkbox,'Value',0)
        set(handles.SpeakerCh7Checkbox,'Value',0)
        set(handles.SpeakerCh8Checkbox,'Value',0)
        
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
        
        %Sai
        set(handles.IO1Checkbox2,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox2,'Value',0)
        set(handles.IO5Checkbox2,'Value',0)
        set(handles.IO7Checkbox2,'Value',0)
        set(handles.IO9Checkbox2,'Value',0)
        set(handles.IO11Checkbox2,'Value',0)
        set(handles.IO13Checkbox2,'Value',0)
        set(handles.IO15Checkbox2,'Value',0)
        
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
        %SAI
        set(handles.IO33Checkbox2,'Value',0)
        set(handles.IO35Checkbox2,'Value',0)
        set(handles.IO37Checkbox2,'Value',0)
        set(handles.IO39Checkbox2,'Value',0)
        set(handles.IO41Checkbox2,'Value',0)
        set(handles.IO43Checkbox2,'Value',0)
        set(handles.IO45Checkbox2,'Value',0)
        set(handles.IO47Checkbox2,'Value',0)
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
        %SAI
        set(handles.booth5Button,'Value',0)
        set(handles.booth6Button,'Value',0)
        set(handles.booth7Button,'Value',0)
        set(handles.booth8Button,'Value',0)
        
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',1)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        %SAI
        set(handles.SpeakerCh5Checkbox,'Value',0)
        set(handles.SpeakerCh6Checkbox,'Value',0)
        set(handles.SpeakerCh7Checkbox,'Value',0)
        set(handles.SpeakerCh8Checkbox,'Value',0)
        
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
        %SAI
        set(handles.IO1Checkbox2,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox2,'Value',0)
        set(handles.IO5Checkbox2,'Value',0)
        set(handles.IO7Checkbox2,'Value',0)
        set(handles.IO9Checkbox2,'Value',0)
        set(handles.IO11Checkbox2,'Value',0)
        set(handles.IO13Checkbox2,'Value',0)
        set(handles.IO15Checkbox2,'Value',0)
        
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
        %SAI
        set(handles.IO33Checkbox2,'Value',0)
        set(handles.IO35Checkbox2,'Value',0)
        set(handles.IO37Checkbox2,'Value',0)
        set(handles.IO39Checkbox2,'Value',0)
        set(handles.IO41Checkbox2,'Value',0)
        set(handles.IO43Checkbox2,'Value',0)
        set(handles.IO45Checkbox2,'Value',0)
        set(handles.IO47Checkbox2,'Value',0)
        
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
        %SAI
        set(handles.booth5Button,'Value',0)
        set(handles.booth6Button,'Value',0)
        set(handles.booth7Button,'Value',0)
        set(handles.booth8Button,'Value',0)
        
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',1)
        %SAI
        set(handles.SpeakerCh5Checkbox,'Value',0)
        set(handles.SpeakerCh6Checkbox,'Value',0)
        set(handles.SpeakerCh7Checkbox,'Value',0)
        set(handles.SpeakerCh8Checkbox,'Value',0)
        
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
        %SAI
        set(handles.IO1Checkbox2,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox2,'Value',0)
        set(handles.IO5Checkbox2,'Value',0)
        set(handles.IO7Checkbox2,'Value',0)
        set(handles.IO9Checkbox2,'Value',0)
        set(handles.IO11Checkbox2,'Value',0)
        set(handles.IO13Checkbox2,'Value',0)
        set(handles.IO15Checkbox2,'Value',0)
        
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
        %SAI
        set(handles.IO33Checkbox2,'Value',0)
        set(handles.IO35Checkbox2,'Value',0)
        set(handles.IO37Checkbox2,'Value',0)
        set(handles.IO39Checkbox2,'Value',0)
        set(handles.IO41Checkbox2,'Value',0)
        set(handles.IO43Checkbox2,'Value',0)
        set(handles.IO45Checkbox2,'Value',0)
        set(handles.IO47Checkbox2,'Value',0)
        
    case 5 %SAIAIIAIOAIAIIAIAIIAIAIAI and basil
        %Assign the appropriate value to handles.booth
        handles.booth = 5;
        
        handles.feeder = 8;
        handles.lights = 4;
        
        %         handles.feederStatus = 0;
        %         handles.lightsStatus = 1;
        
        %adjust the GUI I/O checkmarks
        set(handles.booth1Button,'Value',0)
        set(handles.booth2Button,'Value',0)
        set(handles.booth3Button,'Value',0)
        set(handles.booth4Button,'Value',0)
        
        % BASILIO
        set(handles.booth5Button,'Value',1)
        set(handles.booth6Button,'Value',0)
        set(handles.booth7Button,'Value',0)
        set(handles.booth8Button,'Value',0)
        %
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        %Bsilio Sai
        set(handles.SpeakerCh5Checkbox,'Value',1)
        set(handles.SpeakerCh6Checkbox,'Value',0)
        set(handles.SpeakerCh7Checkbox,'Value',0)
        set(handles.SpeakerCh8Checkbox,'Value',0)
        
        % Set the booth-specific checkmarks in the GUI
        %Inputs
        set(handles.IO1Checkbox,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox,'Value',0)
        set(handles.IO5Checkbox,'Value',0)
        set(handles.IO7Checkbox,'Value',0)
        set(handles.IO9Checkbox,'Value',0)
        set(handles.IO11Checkbox,'Value',0)
        set(handles.IO13Checkbox,'Value',0)
        set(handles.IO15Checkbox,'Value',0)
        
        %Basilio and Sai changed this part, we believe this is the correct
        %course of a-action even though Sai does not know much about Matlab
        set(handles.IO1Checkbox2,'Value',1) %dio.Line(24)
        set(handles.IO3Checkbox2,'Value',0)
        set(handles.IO5Checkbox2,'Value',0)
        set(handles.IO7Checkbox2,'Value',0)
        set(handles.IO9Checkbox2,'Value',1)
        set(handles.IO11Checkbox2,'Value',0)
        set(handles.IO13Checkbox2,'Value',0)
        set(handles.IO15Checkbox2,'Value',0)
        
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
        set(handles.IO39Checkbox,'Value',0)
        set(handles.IO41Checkbox,'Value',0)
        set(handles.IO43Checkbox,'Value',0)
        set(handles.IO45Checkbox,'Value',0)
        set(handles.IO47Checkbox,'Value',0)
        %baSAI
        set(handles.IO33Checkbox2,'Value',1)
        set(handles.IO35Checkbox2,'Value',0)
        set(handles.IO37Checkbox2,'Value',0)
        set(handles.IO39Checkbox2,'Value',0)
        set(handles.IO41Checkbox2,'Value',1)
        set(handles.IO43Checkbox2,'Value',0)
        set(handles.IO45Checkbox2,'Value',0)
        set(handles.IO47Checkbox2,'Value',0)
        
    case 6
        %Assign the appropriate value to handles.booth
        handles.booth = 6;
        
        handles.feeder = 7;
        handles.lights = 3;
        
        %         handles.feederStatus = 0;
        %         handles.lightsStatus = 1;
        
        %adjust the GUI I/O checkmarks
        set(handles.booth1Button,'Value',0)
        set(handles.booth2Button,'Value',0)
        set(handles.booth3Button,'Value',0)
        set(handles.booth4Button,'Value',0)
        %baboolio
        set(handles.booth5Button,'Value',0)
        set(handles.booth6Button,'Value',1)
        set(handles.booth7Button,'Value',0)
        set(handles.booth8Button,'Value',0)
        
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        %baboolian
        set(handles.SpeakerCh5Checkbox,'Value',0)
        set(handles.SpeakerCh6Checkbox,'Value',1)
        set(handles.SpeakerCh7Checkbox,'Value',0)
        set(handles.SpeakerCh8Checkbox,'Value',0)
        
        % Set the booth-specific checkmarks in the GUI
        %Inputs
        set(handles.IO1Checkbox,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox,'Value',0)
        set(handles.IO5Checkbox,'Value',0)
        set(handles.IO7Checkbox,'Value',0)
        set(handles.IO9Checkbox,'Value',0)
        set(handles.IO11Checkbox,'Value',0)
        set(handles.IO13Checkbox,'Value',0)
        set(handles.IO15Checkbox,'Value',0)
        
        %Sai
        set(handles.IO1Checkbox2,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox2,'Value',1)
        set(handles.IO5Checkbox2,'Value',0)
        set(handles.IO7Checkbox2,'Value',0)
        set(handles.IO9Checkbox2,'Value',0)
        set(handles.IO11Checkbox2,'Value',1)
        set(handles.IO13Checkbox2,'Value',0)
        set(handles.IO15Checkbox2,'Value',0)
        
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
        set(handles.IO39Checkbox,'Value',0)
        set(handles.IO41Checkbox,'Value',0)
        set(handles.IO43Checkbox,'Value',0)
        set(handles.IO45Checkbox,'Value',0)
        set(handles.IO47Checkbox,'Value',0)
        %SAI
        set(handles.IO33Checkbox2,'Value',0)
        set(handles.IO35Checkbox2,'Value',1)
        set(handles.IO37Checkbox2,'Value',0)
        set(handles.IO39Checkbox2,'Value',0)
        set(handles.IO41Checkbox2,'Value',0)
        set(handles.IO43Checkbox2,'Value',1)
        set(handles.IO45Checkbox2,'Value',0)
        set(handles.IO47Checkbox2,'Value',0)
    case 7
        %Assign the appropriate value to handles.booth
        handles.booth = 7;
        
        handles.feeder = 6;
        handles.lights = 2;
        
        %         handles.feederStatus = 0;
        %         handles.lightsStatus = 1;
        
        %adjust the GUI I/O checkmarks
        set(handles.booth1Button,'Value',0)
        set(handles.booth2Button,'Value',0)
        set(handles.booth3Button,'Value',0)
        set(handles.booth4Button,'Value',0)
        %SAI
        set(handles.booth5Button,'Value',0)
        set(handles.booth6Button,'Value',0)
        set(handles.booth7Button,'Value',1)
        set(handles.booth8Button,'Value',0)
        
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        %SAI
        set(handles.SpeakerCh5Checkbox,'Value',0)
        set(handles.SpeakerCh6Checkbox,'Value',0)
        set(handles.SpeakerCh7Checkbox,'Value',1)
        set(handles.SpeakerCh8Checkbox,'Value',0)
        
        % Set the booth-specific checkmarks in the GUI
        %Inputs
        set(handles.IO1Checkbox,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox,'Value',0)
        set(handles.IO5Checkbox,'Value',0)
        set(handles.IO7Checkbox,'Value',0)
        set(handles.IO9Checkbox,'Value',0)
        set(handles.IO11Checkbox,'Value',0)
        set(handles.IO13Checkbox,'Value',0)
        set(handles.IO15Checkbox,'Value',0)
        %SAI
        set(handles.IO1Checkbox2,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox2,'Value',0)
        set(handles.IO5Checkbox2,'Value',1)
        set(handles.IO7Checkbox2,'Value',0)
        set(handles.IO9Checkbox2,'Value',0)
        set(handles.IO11Checkbox2,'Value',0)
        set(handles.IO13Checkbox2,'Value',1)
        set(handles.IO15Checkbox2,'Value',0)
        
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
        set(handles.IO39Checkbox,'Value',0)
        set(handles.IO41Checkbox,'Value',0)
        set(handles.IO43Checkbox,'Value',0)
        set(handles.IO45Checkbox,'Value',0)
        set(handles.IO47Checkbox,'Value',0)
        %SAI
        set(handles.IO33Checkbox2,'Value',0)
        set(handles.IO35Checkbox2,'Value',0)
        set(handles.IO37Checkbox2,'Value',1)
        set(handles.IO39Checkbox2,'Value',0)
        set(handles.IO41Checkbox2,'Value',0)
        set(handles.IO43Checkbox2,'Value',0)
        set(handles.IO45Checkbox2,'Value',1)
        set(handles.IO47Checkbox2,'Value',0)
        
    case 8
        %Assign the appropriate value to handles.booth
        handles.booth = 8;
        
        handles.feeder = 5;
        handles.lights = 1;
        
        %         handles.feederStatus = 0;
        %         handles.lightsStatus = 1;
        
        %adjust the GUI I/O checkmarks
        set(handles.booth1Button,'Value',0)
        set(handles.booth2Button,'Value',0)
        set(handles.booth3Button,'Value',0)
        set(handles.booth4Button,'Value',0)
        %SAI
        set(handles.booth5Button,'Value',0)
        set(handles.booth6Button,'Value',0)
        set(handles.booth7Button,'Value',0)
        set(handles.booth8Button,'Value',1)
        
        set(handles.SpeakerCh1Checkbox,'Value',0)
        set(handles.SpeakerCh2Checkbox,'Value',0)
        set(handles.SpeakerCh3Checkbox,'Value',0)
        set(handles.SpeakerCh4Checkbox,'Value',0)
        %SAI
        set(handles.SpeakerCh5Checkbox,'Value',0)
        set(handles.SpeakerCh6Checkbox,'Value',0)
        set(handles.SpeakerCh7Checkbox,'Value',0)
        set(handles.SpeakerCh8Checkbox,'Value',1)
        
        % Set the booth-specific checkmarks in the GUI
        %Inputs
        set(handles.IO1Checkbox,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox,'Value',0)
        set(handles.IO5Checkbox,'Value',0)
        set(handles.IO7Checkbox,'Value',0)
        set(handles.IO9Checkbox,'Value',0)
        set(handles.IO11Checkbox,'Value',0)
        set(handles.IO13Checkbox,'Value',0)
        set(handles.IO15Checkbox,'Value',0)
        %SAI
        set(handles.IO1Checkbox2,'Value',0) %dio.Line(24)
        set(handles.IO3Checkbox2,'Value',0)
        set(handles.IO5Checkbox2,'Value',0)
        set(handles.IO7Checkbox2,'Value',1)
        set(handles.IO9Checkbox2,'Value',0)
        set(handles.IO11Checkbox2,'Value',0)
        set(handles.IO13Checkbox2,'Value',0)
        set(handles.IO15Checkbox2,'Value',1)
        
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
        set(handles.IO39Checkbox,'Value',0)
        set(handles.IO41Checkbox,'Value',0)
        set(handles.IO43Checkbox,'Value',0)
        set(handles.IO45Checkbox,'Value',0)
        set(handles.IO47Checkbox,'Value',0)
        %SAI
        set(handles.IO33Checkbox2,'Value',0)
        set(handles.IO35Checkbox2,'Value',0)
        set(handles.IO37Checkbox2,'Value',0)
        set(handles.IO39Checkbox2,'Value',1)
        set(handles.IO41Checkbox2,'Value',0)
        set(handles.IO43Checkbox2,'Value',0)
        set(handles.IO45Checkbox2,'Value',0)
        set(handles.IO47Checkbox2,'Value',1)
end


%% Select the audio output device and the stereo channel
switch handles.booth
    case 1
        handles.speaker = 11;
        handles.channelGain = [1 0];
    case 2
        handles.speaker = 11;
        handles.channelGain = [0 1];
    case 3
        handles.speaker = 14;
        handles.channelGain = [1 0];
    case 4
        handles.speaker = 14;
        handles.channelGain = [0 1];
    case 5
        handles.speaker = 16;
        handles.channelGain = [1 0];
    case 6
        handles.speaker = 16;
        handles.channelGain = [0 1];
    case 7
        handles.speaker = 10;
        handles.channelGain = [1 0];
    case 8
        handles.speaker = 10;
        handles.channelGain = [0 1];
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
boothStatus.lights = handles.lightsStatus; %Light %TODO: keep an eye on these lines
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