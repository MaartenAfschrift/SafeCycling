
%% Get adapted triggers
%------------------------


% Path information
DataPath  = 'S:\Data\fietsproef\Data\MatData';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas       = {'normal','slow','DualTask','extra','extra2','extra3'};

%% Get information on adapted files

ct = 1;
% loop over all subjects
for s = 1:nPP
    ppPath = ['pp_' num2str(s)];
    for f = 1:length(Folders)
        for i=1:3            
            % load the data
            OutName = [OrderMeas{i} '_data.mat'];
            OutPathMat = fullfile(DataPath,ppPath,Folders{f});
            filename = fullfile(OutPathMat,OutName);            
            if exist(filename,'file')
                % load the mat file (processed with ExampleBatch2)
                load(filename,'tTrigger','Data','header');                 
                if isfield(Data,'BoolCheckTrigger') && Data.BoolCheckTrigger
                    TriggerAdapted(ct).filename = filename;
                    TriggerAdapted(ct).DataPath = DataPath;
                    TriggerAdapted(ct).subj = s;
                    TriggerAdapted(ct).folder = f;
                    TriggerAdapted(ct).trial = i;
                    TriggerAdapted(ct).tTriggerRaw = Data.tTriggerRaw;
                    TriggerAdapted(ct).tTrigger = tTrigger;
                    ct = ct + 1;
                    disp([ './' fullfile(ppPath,Folders{f},OutName) ' was adapted']);
                end                
            end            
        end
    end
end
save('TriggerAdapated.mat','TriggerAdapted');

            




