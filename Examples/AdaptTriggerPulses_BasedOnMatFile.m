%% Settings
% Path information
clear all; close all; clc;

DataPath  = 'E:\Data\Fietsproef\MatData';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas       = {'normal','slow','DualTask','extra','extra2','extra3'};

% file with information on adapted triggers
load(fullfile(DataPath,'TriggerAdapated.mat'),'TriggerAdapted');

%% Adapt triggers based on TriggerAdapated.mat

nFiles = length(TriggerAdapted);
for i = 1:nFiles  
    % get the relative path to the file (Datapath might be different)
    dPathProc = TriggerAdapted(i).DataPath;
    FilenameProc = TriggerAdapted(i).filename;
    i0 = length(dPathProc) + 1;
    RelPath = FilenameProc(i0:end);
    filename = fullfile(DataPath,RelPath);
    
    % load the datafile
    if exist(filename,'file')
        load(filename,'tTrigger','Data','header');
        Data.tTriggerRaw = tTrigger;
        tTrigger = TriggerAdapted(i).tTrigger;
        Data.BoolCheckTrigger = true;
        save(filename,'tTrigger','Data','header');
    else
        disp(['Error !: could not find file ' filename]);
    end
    disp(['File: ' num2str(i) '/' num2str(nFiles)]);
end