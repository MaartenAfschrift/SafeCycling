


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

% loop over all subjects
for s = 10
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
                load(filename,'tTrigger','Data','header');                
                
                % evaluate if we have the expected number of trigger pulses
                nTrigger = length(tTrigger);
                BoolError = nExpect~=nTrigger;      
                
                % evaluate if File was already analysed
                BoolAnalyzed = false;
                if isfield(Data,'BoolCheckTrigger')
                    BoolAnalyzed = Data.BoolCheckTrigger;
                end
                ErrorGUI= false;
                if isfield(Data,'ErrorTriggers')
                     ErrorGUI = Data.ErrorTriggers;
                end
                
                % we also want to re-analyse that files that had originally
                % an error, but this error was removed.
                if BoolAnalyzed  && Bool_ReAnalyse
                    BoolError = true;
                end
                
                if BoolError && ~BoolAnalyzed && ~ErrorGUI
                   
                    % GUI to change trigger pulses
                    tTriggerRaw = tTrigger;
%                     [tTrigger,BoolSkipped,BoolErrorGUI] = Control_Triggers(Data,tTrigger,...
%                         nExpect,filename,PosFigure);                    
                    [tTrigger,BoolSkipped,BoolErrorGUI] = Control_TriggersV2(Data,tTrigger,...
                        nExpect,filename,PosFigure);
                    
                    % Boolean to determine if file was analysed
                    if ~BoolSkipped
                         Data.BoolCheckTrigger = true;
                    else
                         Data.BoolCheckTrigger = false;
                    end
                    
                    if BoolErrorGUI
                        Data.ErrorTriggers = true;
                    else
                        Data.ErrorTriggers = false;
                    end
                    
                    % store raw data
                    Data.tTriggerRaw = tTriggerRaw;
                    % Save the vector with trigger pulses
                    save(filename,'tTrigger','Data','header');
                end                
            end
        end
    end
end
