


%% Settings

% settings for figure
PosFigure = [561 270  1508  839];

% Boolean to select if you want to re-analyse the data
Bool_ReAnalyse = true;

% Path information
DataPath  = 'E:\Data\Fietsproef\MatData';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas       = {'normal','slow','DualTask','extra','extra2','extra3'};
%% Cleaning up trigger pulses

% get reported error in trigger pulses
[TrigError,ListCall2] = getTriggerError();

ct= 1;
% loop over all subjects
for s = 1:nPP
    ppPath = ['pp_' num2str(s)];
    for f = 1:length(Folders)
        for i=1:3            
            % expect 12 triggers in first trial (callibration) and 11
            % trigers in other trials
            if i ==1
                nExpect = 12;                
            else
                nExpect = 11;
            end
            
            % reported mistakes in the callibration procedure
            if (s==1) || (s==3 && f==2) % known errors
                if i ==2
                    nExpect = 12;
                else
                    nExpect = 11;
                end
            end
            
            % load the data
            OutName = [OrderMeas{i} '_data.mat'];
            OutPathMat = fullfile(DataPath,ppPath,Folders{f});
            filename = fullfile(OutPathMat,OutName);
            if exist(filename,'file')
                % load the mat file (processed with ExampleBatch2)
                load(filename,'tTrigger');
                
                % evaluate if we have the expected number of trigger pulses
                nTrigger = length(tTrigger);
                BoolError = nExpect~=nTrigger;                
                
                if BoolError                    
                    ct = ct+1;
                end
            end
        end
    end
end


disp(['Total number of files with unexpected number of triggers: ' num2str(ct)]);

