function [hObject, eventdata, handles] = InitializeProtocol(protocol,hObject, eventdata, handles)
% Initialize the behavioral protocols.
%
% Copyright (c) 2010
% David M. Schneider
% Columbia University
% Department of Psychology
% July 13, 2010

%% Set up default directories that user may wish to modify
handles.wavDir = 'C:\Users\Admin\Documents\MATLAB\ARTSY-TAFC-Dev-\Waves';
handles.boothStatusDir = 'C:\Users\Admin\Documents\MATLAB\ARTSY-TAFC-Dev-\MonitorNICard';
handles.saveDir = 'C:\Users\Admin\Documents\MATLAB\ARTSY-TAFC-Dev-\Data';
handles.settingsDir = 'C:\Users\Admin\Documents\MATLAB\ARTSY-TAFC-Dev-\Settings';

%% Create list of wave files
if ~isdir(handles.wavDir),
    handles.wavDir = uigetdir(cd, 'Please select the sound directory:');
end
handles.nRepeats = 0;
curDir = cd;
cd(handles.wavDir);
d = dir;
songCount = 1;
handles.songList = [];
for i = 1:length(d),
    if d(i).isdir ~= 1,
        handles.songList{songCount} = d(i).name;
        %pause 
        [handles.allSongs{songCount} handles.fs nbits] = wavread(d(i).name);
        songCount = songCount + 1;
    end
end
cd(curDir);
songCount = songCount - 1;

%% Create the save directory
if ~isdir(handles.saveDir),
    handles.saveDir = uigetdir(cd, 'Please select the save directory:');
end
handles.saveName = 'test';
handles.saveNum = '1';
handles.saveFile = [handles.saveName,'_',num2str(handles.saveNum)];
handles.savePath = [handles.saveDir,'\',handles.saveFile];


%% Set the GUI values to their appropriate default values
% Set the song parameters in the GUI
switch protocol
    case 'Acclimate'
        % The following are parameters regarding basic trial setup
        handles.booth = 0;
        handles.running = 0;
        handles.startOrStop = 0;
        handles.reset = 1;
        
        % The following are GUI parameters
        handles.startDelay = 1;%1; %Delay at the beginning of the task (seconds)
        handles.rewardDur = 1;%2; %Duration of reward for proper response (seconds)
        handles.itiMin = 1;
        handles.itiMax = 6;
        handles.trialNum = 1;
        handles.feederStatus = 0;
        handles.lightsStatus = 0;
        handles.reward = 0;
        
        % Print the user status
        set(handles.statusDisplay,'String','Press START/STOP to begin task...')
        
        % Set the GUI parameters
        set(handles.startDelayEdit,'String',num2str(handles.startDelay));
        set(handles.rewardDurationEdit,'String',num2str(handles.rewardDur));
        set(handles.itiMinEdit,'String',num2str(handles.itiMin));
        set(handles.itiMaxEdit,'String',num2str(handles.itiMax));
        set(handles.nTrialsDisplay,'String',num2str(handles.trialNum));
        set(handles.FeederStatusDisplay,'String',num2str(handles.reward));
        
        % Set the save directory parameters in the GUI
        set(handles.filenameDisplay,'String',handles.saveFile)
        set(handles.saveFileNameEdit,'String',handles.saveName)
        set(handles.saveFileNumberEdit,'String',handles.saveNum)
        
        %Adjust the appropriate values of the feeder and light displays
        set(handles.FeederStatusDisplay,'String',num2str(handles.feederStatus));
        set(handles.LightsStatusDisplay,'String',num2str(handles.lightsStatus));
    case 'Shaping'
        % The following are parameters regarding basic trial setup
        handles.booth = 0;
        handles.running = 0;
        handles.startOrStop = 0;
        handles.reset = 1;
        
        % The following are GUI parameters
        handles.startDelay = 1;%1; %Delay at the beginning of the task (seconds)
        handles.rewardDur = 1;%2; %Duration of reward for proper response (seconds)
        handles.itiMin = 1;
        handles.itiMax = 6;
        handles.trialNum = 1;
        handles.feederStatus = 0;
        handles.lightsStatus = 0;
        handles.reward = 0;
        
        % Print the user status
        set(handles.statusDisplay,'String','Press START/STOP to begin task...')
        
        % Set the GUI parameters
        set(handles.startDelayEdit,'String',num2str(handles.startDelay));
        set(handles.rewardDurationEdit,'String',num2str(handles.rewardDur));
        set(handles.itiMinEdit,'String',num2str(handles.itiMin));
        set(handles.itiMaxEdit,'String',num2str(handles.itiMax));
        set(handles.nTrialsDisplay,'String',num2str(handles.trialNum));
        set(handles.FeederStatusDisplay,'String',num2str(handles.reward));
        
        % Set the save directory parameters in the GUI
        set(handles.filenameDisplay,'String',handles.saveFile)
        set(handles.saveFileNameEdit,'String',handles.saveName)
        set(handles.saveFileNumberEdit,'String',handles.saveNum)
        
        %Adjust the appropriate values of the feeder and light displays
        set(handles.FeederStatusDisplay,'String',num2str(handles.feederStatus));
        set(handles.LightsStatusDisplay,'String',num2str(handles.lightsStatus));
    case 'Preference'
        % The following are parameters regarding basic trial setup
        handles.booth = 0;
        handles.running = 0;
        handles.startOrStop = 0;
        handles.reset = 1;
        
        % The following are GUI parameters
        handles.startDelay = 1;%1; %Delay at the beginning of the task (seconds)
        handles.perchDur = 1;%4; %Minimum duration of perching (seconds)
        handles.itiMin = 1;
        handles.itiMax = 6;
        handles.playProb = 100;%2; %Probability of song playback when on perch (seconds)
        handles.volume = 0;
        handles.blockNum = 1;
        handles.trialNum = 1;
        handles.trialNumLocal = 1;
        handles.repsPerBlock = 1;

        nCountTypes = 2;
        handles.responseCount(1:nCountTypes) = zeros(1,nCountTypes);
        handles.trialNumReinforced(:,nCountTypes) = zeros(1,nCountTypes);
        
        % Print the user status
        set(handles.statusDisplay,'String','Press START/STOP to begin task...')
        
        % Set the song parameters in the GUI
        set(handles.key1SongList,'Max',songCount);
        set(handles.key2SongList,'Max',songCount);
        set(handles.key1SongList,'String',handles.songList);
        set(handles.key2SongList,'String',handles.songList);
        
        % Set the GUI parameters
        set(handles.startDelayEdit,'String',num2str(handles.startDelay));
        set(handles.perchDurationEdit,'String',num2str(handles.perchDur));
        set(handles.itiMinEdit,'String',num2str(handles.itiMin));
        set(handles.itiMaxEdit,'String',num2str(handles.itiMax));
        
        set(handles.playProbEdit,'String',num2str(handles.playProb));
        set(handles.volumeEdit,'String',num2str(handles.volume));
        set(handles.volumeSlider,'Value',handles.volume)
        
        set(handles.repsPerBlockEdit,'String',num2str(handles.repsPerBlock));
        
        % Set the save directory parameters in the GUI
        set(handles.filenameDisplay,'String',handles.saveFile)
        set(handles.saveFileNameEdit,'String',handles.saveName)
        set(handles.saveFileNumberEdit,'String',handles.saveNum)
    case 'Classical'
        % The following are parameters regarding basic trial setup
        handles.booth = 0;
        handles.running = 0;
        handles.startOrStop = 0;
        handles.reset = 1;
        
        % The following are GUI parameters
        handles.startDelay = 1;%1; %Delay at the beginning of the task (seconds)
        handles.stimOutcomeDelay = 1;%4; %Duration for which to monitor responses (seconds)
        handles.rewardDur = 1;%2; %Duration of reward for proper response (seconds)
        handles.punishDur = 1;%10; %Duration of reward for improper response (seconds)
        handles.nullDur = 1;%2; %duration of break for null outcome (seconds)
        handles.itiMin = 1;
        handles.itiMax = 6;
        handles.feederStatus = 0;
        handles.lightsStatus = 0;
        handles.volume = 0;
        handles.blockNum = 1;
        handles.repsPerBlock = 1;
        handles.trialNum = 1;
        handles.trialNumLocal = 1;

        nCountTypes = 3;
        handles.responseCount(1:nCountTypes) = zeros(1,nCountTypes);
        
        % Print the user status
        set(handles.statusDisplay,'String','Press START/STOP to begin task...')
        
        % Set the song parameters in the GUI
        set(handles.goSongList,'Max',songCount);
        set(handles.noGoSongList,'Max',songCount);
        set(handles.catchSongList,'Max',songCount);
        set(handles.goSongList,'String',handles.songList);
        set(handles.noGoSongList,'String',handles.songList);
        set(handles.catchSongList,'String',handles.songList);
        
        % Set the GUI parameters
        set(handles.FeederStatusDisplay,'String',num2str(handles.feederStatus));
        set(handles.LightsStatusDisplay,'String',num2str(handles.lightsStatus));
        
        set(handles.startDelayEdit,'String',num2str(handles.startDelay));
        set(handles.stimOutcomeDelayEdit,'String',num2str(handles.stimOutcomeDelay));
        set(handles.rewardDurationEdit,'String',num2str(handles.rewardDur));
        set(handles.punishDurationEdit,'String',num2str(handles.punishDur));
        set(handles.nullDurationEdit,'String',num2str(handles.nullDur));
        set(handles.itiMinEdit,'String',num2str(handles.itiMin));
        set(handles.itiMaxEdit,'String',num2str(handles.itiMax));
        
        set(handles.repsPerBlockEdit,'String',num2str(handles.repsPerBlock));
        
        set(handles.volumeEdit,'String',num2str(handles.volume));
        set(handles.volumeSlider,'Value',handles.volume)
        
        % Set the save directory parameters in the GUI
        set(handles.filenameDisplay,'String',handles.saveFile)
        set(handles.saveFileNameEdit,'String',handles.saveName)
        set(handles.saveFileNumberEdit,'String',handles.saveNum)
    case 'GoNoGo'
        % The following are parameters regarding basic trial setup
        handles.booth = 0;
        handles.running = 0;
        handles.startOrStop = 0;
        handles.reset = 1;
        
        % The following are the GUI parameters
        handles.startDelay = 1;%1; %Delay at the beginning of the task (seconds)
        handles.preResponseDur = 0; %Delay between stim end and response period beginning (seconds)
        handles.responseDur = 1;%4; %Duration for which to monitor responses (seconds)
        handles.rewardDur = 1;%2; %Duration of reward for proper response (seconds)
        handles.punishDur = 1;%10; %Duration of reward for improper response (seconds)
        handles.nullDur = 1;%2; %duration of break for null outcome (seconds)
        handles.itiMin = 1;
        handles.itiMax = 6;
        handles.feederStatus = 0;
        handles.lightsStatus = 0;
        handles.volume = 0;
        handles.repsPerBlock = 1;
        handles.blockNum = 1;
        handles.trialNum = 1;
        handles.trialNumLocal = 1;
        handles.nRepeats = 0;
        handles.goRewardRate = 100;
        handles.noGoRewardRate = 100;
        handles.reinforceInterval = 50;
        
        handles.key1HitOutcome = [1 0 0];
        handles.key1MissOutcome = [0 0 1];
        handles.key2HitOutcome = [0 1 0];
        handles.key2MissOutcome = [0 0 1];

        nCountTypes = 7;
        handles.responseCount(1:nCountTypes) = zeros(1,nCountTypes);
        handles.responseCountReinforced(1:nCountTypes) = zeros(1,nCountTypes);
        handles.fractionReinforced(1:nCountTypes) = zeros(1,nCountTypes); %[100 0 0 100 0 0];
        handles.nC = 0;
        
        % Print the user status
        set(handles.statusDisplay,'String','Press START/STOP to begin task...')
        
        % Set the song parameters in the GUI
        set(handles.goSongList,'Max',songCount);
        set(handles.noGoSongList,'Max',songCount);
        set(handles.catchSongList,'Max',songCount);
        set(handles.goSongList,'String',handles.songList);
        set(handles.noGoSongList,'String',handles.songList);
        set(handles.catchSongList,'String',handles.songList);
        
        % Set the GUI parameters
        set(handles.startDelayEdit,'String',num2str(handles.startDelay));
        set(handles.preResponseDurationEdit,'String',num2str(handles.preResponseDur));
        set(handles.responseDurationEdit,'String',num2str(handles.responseDur));
        set(handles.rewardDurationEdit,'String',num2str(handles.rewardDur));
        set(handles.punishDurationEdit,'String',num2str(handles.punishDur));
        set(handles.nullDurationEdit,'String',num2str(handles.nullDur));
        set(handles.itiMinEdit,'String',num2str(handles.itiMin));
        set(handles.itiMaxEdit,'String',num2str(handles.itiMax));
        
        set(handles.goRateEdit,'String',num2str(handles.goRewardRate));
        set(handles.nogoRateEdit,'String',num2str(handles.noGoRewardRate));
        set(handles.fractionGoReinforcedDisplay,'String',num2str(handles.fractionReinforced(1)));
        set(handles.fractionNoGoReinforcedDisplay,'String',num2str(handles.fractionReinforced(4)));
        set(handles.bigBlockEdit,'String',num2str(handles.reinforceInterval));
        set(handles.nCatchEdit,'String',num2str(handles.nC));
        
        set(handles.FeederStatusDisplay,'String',handles.feederStatus);
        set(handles.LightsStatusDisplay,'String',handles.lightsStatus);
        
        set(handles.volumeEdit,'String',num2str(handles.volume));
        set(handles.volumeSlider,'Value',handles.volume);
        
        set(handles.repsPerBlockEdit,'String',num2str(handles.repsPerBlock));
        set(handles.nRepeatsDisplay,'String',num2str(handles.nRepeats));
        
        set(handles.Reward1Button,'Value',handles.key1HitOutcome(1));
        set(handles.Punish1Button,'Value',handles.key1HitOutcome(2));
        set(handles.Null1Button,'Value',handles.key1HitOutcome(3));
        
        set(handles.Reward2Button,'Value',handles.key1MissOutcome(1));
        set(handles.Punish2Button,'Value',handles.key1MissOutcome(2));
        set(handles.Null2Button,'Value',handles.key1MissOutcome(3));
        
        set(handles.Reward4Button,'Value',handles.key2HitOutcome(1));
        set(handles.Punish4Button,'Value',handles.key2HitOutcome(2));
        set(handles.Null4Button,'Value',handles.key2HitOutcome(3));
        
        set(handles.Reward5Button,'Value',handles.key2MissOutcome(1));
        set(handles.Punish5Button,'Value',handles.key2MissOutcome(2));
        set(handles.Null5Button,'Value',handles.key2MissOutcome(3));
        
        % Set the save directory parameters in the GUI
        set(handles.filenameDisplay,'String',handles.saveFile)
        set(handles.saveFileNameEdit,'String',handles.saveName)
        set(handles.saveFileNumberEdit,'String',handles.saveNum)
    case 'TAFC'
        % The following are parameters regarding basic trial setup
        handles.booth = 0;
        handles.running = 0;
        handles.startOrStop = 0;
        handles.reset = 1;
        
        % The following are the GUI parameters
        handles.startDelay = 1;%1; %Delay at the beginning of the task (seconds)
        handles.responseDur = 1;%4; %Duration for which to monitor responses (seconds)
        handles.rewardDur = 1;%2; %Duration of reward for proper response (seconds)
        handles.punishDur = 1;%10; %Duration of reward for improper response (seconds)
        handles.nullDur = 1;%2; %duration of break for null outcome (seconds)
        handles.itiMin = 1;
        handles.itiMax = 6;
        handles.feederStatus = 0;
        handles.lightsStatus = 0;
        handles.volume = 0;
        handles.repsPerBlock = 1;
        handles.blockNum = 1;
        handles.trialNum = 1;
        handles.trialNumLocal = 1;
        handles.nRepeats = 0;
        handles.goRewardRate = 100;
        handles.noGoRewardRate = 100;
        handles.reinforceInterval = 50;
        
        handles.key1HitOutcome = [1 0 0];
        handles.key1MissOutcome = [0 1 0];
        handles.key1NROutcome = [0 0 1];
        handles.key2HitOutcome = [1 0 0];
        handles.key2MissOutcome = [0 1 0];
        handles.key2NROutcome = [0 0 1];

        nCountTypes = 7;
        handles.responseCount(1:nCountTypes) = zeros(1,nCountTypes);
        handles.responseCountReinforced(1:nCountTypes) = zeros(1,nCountTypes);
        handles.fractionReinforced(1:nCountTypes) = zeros(1,nCountTypes); %[100 0 0 100 0 0];
        handles.nC = 0;
        
        % Print the user status
        set(handles.statusDisplay,'String','Press START/STOP to begin task...')
        
        % Set the song parameters in the GUI
        set(handles.key1SongList,'Max',songCount);
        set(handles.key2SongList,'Max',songCount);
        set(handles.catchSongList,'Max',songCount);
        set(handles.key1SongList,'String',handles.songList);
        set(handles.key2SongList,'String',handles.songList);
        set(handles.catchSongList,'String',handles.songList);
        
        % Set the GUI parameters
        set(handles.startDelayEdit,'String',num2str(handles.startDelay));
        set(handles.responseDurationEdit,'String',num2str(handles.responseDur));
        set(handles.rewardDurationEdit,'String',num2str(handles.rewardDur));
        set(handles.punishDurationEdit,'String',num2str(handles.punishDur));
        set(handles.nullDurationEdit,'String',num2str(handles.nullDur));
        set(handles.itiMinEdit,'String',num2str(handles.itiMin));
        set(handles.itiMaxEdit,'String',num2str(handles.itiMax));
        
        set(handles.goRateEdit,'String',num2str(handles.goRewardRate));
        set(handles.nogoRateEdit,'String',num2str(handles.noGoRewardRate));
        set(handles.fractionKey1ReinforcedDisplay,'String',num2str(handles.fractionReinforced(1)));
        set(handles.fractionKey2ReinforcedDisplay,'String',num2str(handles.fractionReinforced(4)));
        set(handles.bigBlockEdit,'String',num2str(handles.reinforceInterval));
        set(handles.nCatchEdit,'String',num2str(handles.nC));
        
        set(handles.FeederStatusDisplay,'String',handles.feederStatus);
        set(handles.LightsStatusDisplay,'String',handles.lightsStatus);
        
        set(handles.volumeEdit,'String',num2str(handles.volume));
        set(handles.volumeSlider,'Value',handles.volume);
        
        set(handles.repsPerBlockEdit,'String',num2str(handles.repsPerBlock));
        set(handles.nRepeatsDisplay,'String',num2str(handles.nRepeats));
        
        set(handles.Reward1Button,'Value',handles.key1HitOutcome(1));
        set(handles.Punish1Button,'Value',handles.key1HitOutcome(2));
        set(handles.Null1Button,'Value',handles.key1HitOutcome(3));
        
        set(handles.Reward2Button,'Value',handles.key1MissOutcome(1));
        set(handles.Punish2Button,'Value',handles.key1MissOutcome(2));
        set(handles.Null2Button,'Value',handles.key1MissOutcome(3));
        
        set(handles.Reward3Button,'Value',handles.key1NROutcome(1));
        set(handles.Punish3Button,'Value',handles.key1NROutcome(2));
        set(handles.Null3Button,'Value',handles.key1NROutcome(3));
        
        set(handles.Reward4Button,'Value',handles.key2HitOutcome(1));
        set(handles.Punish4Button,'Value',handles.key2HitOutcome(2));
        set(handles.Null4Button,'Value',handles.key2HitOutcome(3));
        
        set(handles.Reward5Button,'Value',handles.key2MissOutcome(1));
        set(handles.Punish5Button,'Value',handles.key2MissOutcome(2));
        set(handles.Null5Button,'Value',handles.key2MissOutcome(3));
        
        set(handles.Reward6Button,'Value',handles.key2NROutcome(1));
        set(handles.Punish6Button,'Value',handles.key2NROutcome(2));
        set(handles.Null6Button,'Value',handles.key2NROutcome(3));
        
        % Set the save directory parameters in the GUI
        set(handles.filenameDisplay,'String',handles.saveFile)
        set(handles.saveFileNameEdit,'String',handles.saveName)
        set(handles.saveFileNumberEdit,'String',handles.saveNum)
    case 'Yoking'
        % The following are parameters regarding basic trial setup
        handles.booth = 0;
        handles.running = 0;
        handles.startOrStop = 0;
        handles.volume = 0;
        
        % The following are the GUI parameters
        handles.trialNum = 1;
        handles.nTotalTrials = 1;

        % Print the user status
        set(handles.statusDisplay,'String','Press START/STOP to begin task...')
        
        % Get the Yoked song list: keep only the song letters
        handles.yokeList = [];
        for i = 1:length(handles.songList),
            handles.yokeList{i} = handles.songList{i}(1);
        end
        handles.yokeList = unique(handles.yokeList);
        yokeCount = length(handles.yokeList);
            
        % Set the song parameters in the GUI
        set(handles.trainedSongList,'Max',0);
        set(handles.yokedSongList,'Max',yokeCount);
        set(handles.pairsList,'Max',0);
        set(handles.trainedSongList,'String',[]);
        set(handles.yokedSongList,'String',handles.yokeList);
        set(handles.pairsList,'String',[]);
        handles.yokedPairs = [];
        handles.pairDisplay = [];

        set(handles.volumeEdit,'String',num2str(handles.volume));
        set(handles.volumeSlider,'Value',handles.volume);
        
        % Display the loaded file name
        handles.loadedFile = 'Load file...';
        set(handles.filenameDisplay,'String',handles.loadedFile)
end


%% Set up the National Instriments card
% % Configure the ports
% % This device has 3 ports
% % Each port has 8 channels
% % Set up the ports as either input ('In') or outputs ('Out')
% % Each channel on a port must go the same direction
% 
% %MATLAB to NI Translator:
% %NI-Pin   handles.dio.Line(x)   USE
% %1                  24          Key1
% %3                  23          Key1
% %5                  22          Key1
% %7                  21          Key1
% %9                  20          Key2
% %11                 19          Key2
% %13                 18          Key2
% %15                 17          Key2
% %17                 16          (not used)
% %19                 15          (not used)
% %21                 14          (not used)
% %23                 13          (not used)
% %25                 12          (not used)
% %27                 11          (not used)
% %29                 10          (not used)
% %31                 9           (not used)
% %33                 8           Feeder
% %35                 7           Feeder
% %37                 6           Feeder
% %39                 5           Feeder
% %41                 4           Lights
% %43                 3           Lights
% %45                 2           Lights
% %47                 1           Lights
% 
% NI = daqhwinfo('nidaq');
% handles.dio = digitalio(NI.AdaptorName, [NI.InstalledBoardIds{1}]);
% 
% addline(handles.dio, 0:7, 0, 'Out'); %Pins 47-33
% addline(handles.dio, 0:7, 1, 'Out'); %Pins 31-17
% addline(handles.dio, 0:7, 2, 'In'); %Pins 15-1

% This allows the simultaneous control of up to 4 booths from a single
% computer, although each booth is controlled from an independent matlab
% session.
% boothStatus = [feeder1 lights1 feeder2 lights2...];
% boothStatus = [0 0 0 0 0 0 0 0];
% curDir = cd;
% cd(handles.boothStatusDir)
% load boothStatus
% save boothStatus boothStatus
% cd(curDir)

% Set the booth and speaker buttons in the GUI
set(handles.booth1Button,'Value',0)
set(handles.booth2Button,'Value',0)
set(handles.booth3Button,'Value',0)
set(handles.booth4Button,'Value',0)
%SASI
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
set(handles.IO39Checkbox,'Value',0)
set(handles.IO41Checkbox,'Value',0)
set(handles.IO43Checkbox,'Value',0)
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

%Inactivate the speaker checkboxes
set(handles.SpeakerCh1Checkbox,'Enable','Inactive')
set(handles.SpeakerCh2Checkbox,'Enable','Inactive')
set(handles.SpeakerCh3Checkbox,'Enable','Inactive')
set(handles.SpeakerCh4Checkbox,'Enable','Inactive')
%SAI
set(handles.SpeakerCh5Checkbox,'Enable','Inactive')
set(handles.SpeakerCh6Checkbox,'Enable','Inactive')
set(handles.SpeakerCh7Checkbox,'Enable','Inactive')
set(handles.SpeakerCh8Checkbox,'Enable','Inactive')

%Inactivate the I/O input checkboxes
set(handles.IO1Checkbox,'Enable','Inactive')
set(handles.IO3Checkbox,'Enable','Inactive')
set(handles.IO5Checkbox,'Enable','Inactive')
set(handles.IO7Checkbox,'Enable','Inactive')
set(handles.IO9Checkbox,'Enable','Inactive')
set(handles.IO11Checkbox,'Enable','Inactive')
set(handles.IO13Checkbox,'Enable','Inactive')
set(handles.IO15Checkbox,'Enable','Inactive')

%SAI
set(handles.IO1Checkbox2,'Enable','Inactive')
set(handles.IO3Checkbox2,'Enable','Inactive')
set(handles.IO5Checkbox2,'Enable','Inactive')
set(handles.IO7Checkbox2,'Enable','Inactive')
set(handles.IO9Checkbox2,'Enable','Inactive')
set(handles.IO11Checkbox2,'Enable','Inactive')
set(handles.IO13Checkbox2,'Enable','Inactive')
set(handles.IO15Checkbox2,'Enable','Inactive')

%Inactivate the I/O output checkboxes
% set(handles.IO17Checkbox,'Enable','Inactive')
% set(handles.IO19Checkbox,'Enable','Inactive')
% set(handles.IO21Checkbox,'Enable','Inactive')
% set(handles.IO23Checkbox,'Enable','Inactive')
% set(handles.IO25Checkbox,'Enable','Inactive')
% set(handles.IO27Checkbox,'Enable','Inactive')
% set(handles.IO29Checkbox,'Enable','Inactive')
% set(handles.IO31Checkbox,'Enable','Inactive')

%Inactivate the I/O output checkboxes
set(handles.IO33Checkbox,'Enable','Inactive')
set(handles.IO35Checkbox,'Enable','Inactive')
set(handles.IO37Checkbox,'Enable','Inactive')
set(handles.IO39Checkbox,'Enable','Inactive')
set(handles.IO41Checkbox,'Enable','Inactive')
set(handles.IO43Checkbox,'Enable','Inactive')
set(handles.IO45Checkbox,'Enable','Inactive')
set(handles.IO47Checkbox,'Enable','Inactive')

%SAI
set(handles.IO33Checkbox2,'Enable','Inactive')
set(handles.IO35Checkbox2,'Enable','Inactive')
set(handles.IO37Checkbox2,'Enable','Inactive')
set(handles.IO39Checkbox2,'Enable','Inactive')
set(handles.IO41Checkbox2,'Enable','Inactive')
set(handles.IO43Checkbox2,'Enable','Inactive')
set(handles.IO45Checkbox2,'Enable','Inactive')
set(handles.IO47Checkbox2,'Enable','Inactive')