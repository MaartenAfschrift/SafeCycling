%% backup data
%--------------


% we want to store all the 'manual' processing using the GUI's




%% Settings
close all; clc;
% settings for figure (you can adjust these positions if you want)
PosFigure = [146         102        1571         876];

% Boolean to select if you want to re-analyse the data
Bool_ReAnalyse = false;

% Path information
DataPath  = 'S:\Data\fietsproef\Data\MatData';
addpath(genpath('C:\Users\r0721298\Documents\software\SafeCycling'));
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas = {'normal','slow','DualTask'};
%% Cleaning up trigger pulses

% get reported error in trigger pulses
[TrigError,ListCall2] = getTriggerError();

% loop over all subjects
warning off
ct = 1;
for s = 1:nPP
    ppPath = ['pp_' num2str(s)];
    for f = 1:length(Folders)
        for i=1:length(OrderMeas)
            % load the data
            OutName = [OrderMeas{i} '_data.mat'];
            OutPathMat = fullfile(DataPath,ppPath,Folders{f});
            filename = fullfile(OutPathMat,OutName);
            if exist(filename,'file')
                % load the mat file (processed with ExampleBatch2)
                load(filename,'GUIvar','Events'); 
                if exist('GUIvar','var') && exist('Events','var') && ...
                        ~isempty(GUIvar) && ~isempty(Events)
                   GUIInfo(ct).s = s;
                   GUIInfo(ct).bike = Folders{f};
                   GUIInfo(ct).task = OrderMeas{i};
                   GUIInfo(ct).GUIvar = GUIvar;
                   GUIInfo(ct).Events = Events;
                   ct = ct+1;
                end                    
            end
        end
    end
end
save(fullfile(DataPath,'GUIInfo.mat'),'GUIInfo');
warning on


