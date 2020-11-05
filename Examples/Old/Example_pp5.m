%% Example script to load and plot data
%--------------------------------------
clear all; close all;
% path to folder with txt files
ExportPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\EXPERIMENTEN\pp_12\Classic';

% filenames + sensors ID's
filename = 'trial_'; % filename
ExtID = {'003','002'};  % (1) output new station, (0) output old station.
BoolIDStation  = 0; % Boolean: 1 if ID name of the station is in the output name of the file (ID name is for example _00200387) 

% location of sensors
Loc  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
nsensor = length(Loc);

% sequential order of events
OrderEvents     = {'Call1','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','brake'};

% get and process the data
[Data,tTrigger,header] = CombineRawData(ExportPath,filename,Loc,OrderEvents,ExtID,0);

% plot default figure
PlotDefaultFigures(Data);