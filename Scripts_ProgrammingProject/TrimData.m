%% Trim data to reduce size:
%----------------------------

% general information
DataPath  = 'E:\Data\Fietsproef';
FigPath = 'E:\Data\Fietsproef\Figures\HingeSteer';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas = {'normal','slow','DualTask','extra','extra2','extra3'};
SensorLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
load(fullfile(DataPath,'RawData','ppInfo.mat'),'ppYoung','ppEld');  % Boolean with young and older subjects

% select what we want to export 
ParcousSelected = {'small','slalom','FullTurn'};
SensorSelected  = {'Trunk','Frame','Steer'};
headerOut = {'time','acc_x','acc_y','acc_z','AngVel_x','AngVel_y','AngVel_z'};
OutPath = 'E:\Data\Fietsproef\MatData_assignment2';

BoolSavedSubj = zeros(nPP,1);

for s = 1:nPP % subject
     ppPath = ['pp_' num2str(s)];
    for f = 1:length(Folders) % classic and ebike
        for i =1:length(OrderMeas) % normal, slow, dualtask
            OutName = [OrderMeas{i} '_data.mat'];
            OutPathMat = fullfile(DataPath,'MatData',ppPath,Folders{f});
            filename = fullfile(OutPathMat,OutName);
            fileSteer = fullfile(OutPathMat,'RotAxis_Steer.mat');
            if exist(filename,'file') && exist(fileSteer,'file')
                load(filename,'Phases');
                load(fileSteer,'Rax');
                if exist('Phases','var')
                    BoolSave = true;
                    % trim the data to what is needed
                    SensorDat = struct;
                    for k = 1:length(ParcousSelected)
                        for r = 1:length(SensorSelected)
                            Dsel = Phases.(SensorSelected{r}).(ParcousSelected{k});
                            Dmat = [Dsel.t' Dsel.AccWorld Dsel.QdWorld];
                            if ~isempty(Dsel.R)
                                SensorDat.(SensorSelected{r}).(ParcousSelected{k}).data =  Dmat;
                                SensorDat.(SensorSelected{r}).(ParcousSelected{k}).header = headerOut;
                                SensorDat.(SensorSelected{r}).(ParcousSelected{k}).R = Dsel.R;
                                SensorDat.(SensorSelected{r}).(ParcousSelected{k}).Rax = Rax;
                            else
                                BoolSave = false;
                            end
                        end
                    end
                    
                    % save the matlabfile
                    if BoolSave
                        OutPathSel = fullfile(OutPath,ppPath,Folders{f});
                        if  ~isfolder(OutPathSel)
                            mkdir(OutPathSel)
                        end
                        save(fullfile(OutPathSel,OutName),'SensorDat');
                        BoolSavedSubj(s) = 1;
                    end
                    clear Phases Rax
                end
            end
        end
    end
end



