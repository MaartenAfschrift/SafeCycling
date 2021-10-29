


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
% OrderMeas = {'normal','slow','DualTask','extra','extra2','extra3'};
OrderMeas = {'normal'};
%% Cleaning up trigger pulses

% get reported error in trigger pulses
[TrigError,ListCall2] = getTriggerError();

% loop over all subjects
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
                load(filename,'Phases','GUIvar','Events'); 
                
                % flow control variables
                BoolAnalyzed = false;
                BoolDrift = false;
                errorFlag = false;
                if ~exist('GUIvar','var')
                    GUIvar = [];                    
                end
                if ~exist('Events','var')
                    Events = [];                    
                end
                
                if ~isempty(GUIvar) && isfield(GUIvar,'slalom_Analyzed')
                    BoolAnalyzed = GUIvar.slalom_Analyzed;
                end
                if ~isempty(GUIvar) && isfield(GUIvar,'slalom_Drift')
                    BoolDrift = GUIvar.slalom_Drift;
                end
                if ~isempty(GUIvar) && isfield(GUIvar,'Slalom_errorFlag')
                    errorFlag = GUIvar.Slalom_errorFlag;
                end
                
                if (~BoolAnalyzed && ~errorFlag) || Bool_ReAnalyse
                    % GUI to detect start and stop
                   [tStart,tEnd,BoolSkipped,BoolDrift] = ...
                       GUI_Slalom_Events(Phases,filename,PosFigure);
                   
                    % store raw data
                    Events.slalom = [tStart tEnd];
                    if ~isnan(tStart) && ~isnan(tEnd) && ~BoolSkipped 
                        GUIvar.slalom_Analyzed = true;
                    end
                    GUIvar.slalom_Drift = BoolDrift;
                    GUIvar.slalom_errorFlag = BoolSkipped;
                    
                    % Save the vector with trigger pulses
                    save(filename,'Events','GUIvar','-append');
                end   
                clear Phases GUIvar Events
            end
        end
    end
end
