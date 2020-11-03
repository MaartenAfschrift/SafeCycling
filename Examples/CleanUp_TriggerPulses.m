


%% Path info 
DataPath  = 'E:\Data\Fietsproef\MatData';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas       = {'normal','slow','DualTask','extra','extra2','extra3'};
OrderEvents_Call     = {'Call-person','Call-bike','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};
OrderEvents_Norm     = {'Start','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};


Bool_ReAnalyse = true;
%% Cleaning up trigger pulses

% get reported error in trigger pulses
[TrigError,ListCall2] = getTriggerError();

% loop over all subjects

for s = 1:nPP
    ppPath = ['pp_' num2str(s)];
    for f = 1:length(Folders)
        for i=1:3
            if i ==1
                nExpect = 12;
                
            else
                nExpect = 11;
            end
            if (s==1) || (s==3 && f==2) % known errors
                if i ==2
                    nExpect = 12;                    
                else
                    nExpect = 11;
                end
            end
            if nExpect == 12
                OrderEvents = OrderEvents_Call;
            else
                OrderEvents =  OrderEvents_Norm;
            end
            
            OutName = [OrderMeas{i} '_data.mat'];
            OutPathMat = fullfile(DataPath,ppPath,Folders{f});
            filename = fullfile(OutPathMat,OutName);
            if exist(filename,'file')
                load(filename,'tTrigger','Data','header');
                
                % we will debug the triggers here
                % first check if this file is in the list with errors
                nTrigger = length(tTrigger);
                % second check: has the file the number of trigger we
                % expect ?
                BoolError = nExpect~=nTrigger;                 
                % third check based on  identification full turn
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
                
                if BoolError && (~BoolAnalyzed || Bool_ReAnalyse) && ~ErrorGUI
                   
                    tTriggerRaw = tTrigger;
                    [tTrigger,BoolSkipped,BoolErrorGUI] = Control_Triggers(Data,tTrigger,nExpect,filename);
                    
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
