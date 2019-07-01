function [hObject, eventdata, handles] = CloseBooth(hObject, eventdata, handles)
% Close one of the four booths.
%
% Copyright (c) 2010
% David M. Schneider
% Columbia University
% Department of Psychology
% July 13, 2010

cd(handles.boothStatusDir)

handles.lightsStatus = 1; %Sai: 1 turns off lights
handles.feederStatus = 0;

%Set the boothStatus
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

%Assign the appropriate value to handles.booth
handles.booth = 0;

%Adjust the appropriate values of the feeder and light displays
if exist('handles.FeederStatusDisplay','var'),
    set(handles.FeederStatusDisplay,'String',num2str(handles.feederStatus))
    set(handles.LightsStatusDisplay,'String',num2str(handles.lightsStatus))
end

%adjust the GUI I/O checkmarks
set(handles.booth1Button,'Value',0)
set(handles.booth2Button,'Value',0)
set(handles.booth3Button,'Value',0)
set(handles.booth4Button,'Value',0)
%SAi
set(handles.booth5Button,'Value',0)
set(handles.booth6Button,'Value',0)
set(handles.booth7Button,'Value',0)
set(handles.booth8Button,'Value',0)

set(handles.SpeakerCh1Checkbox,'Value',0)
set(handles.SpeakerCh2Checkbox,'Value',0)
set(handles.SpeakerCh3Checkbox,'Value',0)
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
set(handles.IO5Checkbox,'Value',0)
set(handles.IO7Checkbox,'Value',0)
set(handles.IO9Checkbox,'Value',0)
set(handles.IO11Checkbox,'Value',0)
set(handles.IO13Checkbox,'Value',0)
set(handles.IO15Checkbox,'Value',0)
%basilio
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
set(handles.IO39Checkbox,'Value',0)
set(handles.IO41Checkbox,'Value',0)
set(handles.IO43Checkbox,'Value',0)
set(handles.IO45Checkbox,'Value',0)
set(handles.IO47Checkbox,'Value',0)
%boolio
set(handles.IO33Checkbox2,'Value',0)
set(handles.IO35Checkbox2,'Value',0)
set(handles.IO37Checkbox2,'Value',0)
set(handles.IO39Checkbox2,'Value',0)
set(handles.IO41Checkbox2,'Value',0)
set(handles.IO43Checkbox2,'Value',0)
set(handles.IO45Checkbox2,'Value',0)
set(handles.IO47Checkbox2,'Value',0)