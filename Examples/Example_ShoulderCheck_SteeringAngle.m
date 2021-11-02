%% Example on how to analyse data
%--------------------------------

clear all; close all; clc;

%DataPath  = 'E:\fietsproef\Data';
DataPath = 'S:\Data\fietsproef\Data';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas = {'normal'};
SensorLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};


% load the info of the folders
load(fullfile(DataPath,'MatData','ppInfo.mat'),'ppYoung','ppEld');

% flow control
ComputeDataMatrix = true; % Run part to compute datamatrix (or load saved .mat file)
BoolPlot2 = false; % individual plot for each subject with the input data to copumpute variance

% tresholds
threshold_drift = 0.3; % 0.3 radians in this task

%% Read the excel table with information on the task

% datapath = 'E:\fietsproef\';
% FileYoung = fullfile(datapath,'opmerkingen proefpersonen.xlsx');
% [ShoulderCheckInfo] = GetShoulderCheckInfo(FileYoung);
%
% ShoulderCheckInfo.pp = [ShoulderCheckInfo.ppIDYoung; ShoulderCheckInfo.ppIDOld];
% ShoulderCheckInfo.data = [ShoulderCheckInfo.DatYoung; ShoulderCheckInfo.DatOlder];
% ShoulderCheckInfo.header = ShoulderCheckInfo.HeadersOlder;


%% Get the Datamatrix
if ComputeDataMatrix
    DataMatrix = nan(100*3*2,6); % pre allocat matrix with all the data
    header_DataMatrix =  {'s-ID','bike-ID','Speed-ID','SteeringAngle','BoolElderly','Error'}; % header for the datamatrix
    diary('LogExample_ShoulderCheck.txt');
    
    ct = 1;
    for s = 1:nPP
        ppPath = ['pp_' num2str(s)];
        %   h1 = figure();
        
        if BoolPlot2
            h2 = figure();
        end
        
        % detect if this is a young or an older subject
        BoolEld = any(ppEld ==s);
        BoolYoung = any(ppYoung ==s);
        if BoolEld && BoolYoung
            disp(['Subject ' num2str(s) ' is both young and old. adapt this in the excel file']);
        end
        
        for f = 1:length(Folders)
            for i =1:length(OrderMeas)
                % load the data
                OutName = [OrderMeas{i} '_data.mat'];
                OutPathMat = fullfile(DataPath,'MatData',ppPath,Folders{f});
                filename = fullfile(OutPathMat,OutName);
                if exist(filename,'file')
                    load(filename,'Phases','header','GUIvar','Events');
                    if ~exist('GUIvar','var')
                        GUIvar = [];
                    end
                    if ~exist('Events','var')
                        Events = [];
                    end
                    
                    if exist('Phases','var')
                        BoolErrorFlag = 0;
                        % get the variance in steer angle
                        if isfield(Phases,'SteerAngle') && ~isempty(Phases.SteerAngle.small.t)
                            
                            
                            %                             % event detection for the dual task
                            %
                            %                             % check if task was performed according to
                            %                             % instructions
                            %                             iData = find(ShoulderCheckInfo.pp== s);
                            %
                            %                             if strcmp(Folders{f},'Classic')
                            %                                 if strcmp(OrderMeas{i},'normal')
                            %                                     headerSel = {'KEGEL NIET GEZIEN-normal-classic',...
                            %                                         'VOET GROND-normal-classic'};
                            %
                            %                                 end
                            %                             elseif strcmp(Folders{f},'EBike')
                            %                                 if strcmp(OrderMeas{i},'normal')
                            %                                     headerSel = {'KEGEL NIET GEZIEN-normal-ebike',...
                            %                                         'VOET GROND-normal-ebike'};
                            %                                 end
                            %                             end
                            %                             % select colIndices
                            %                             IndsColInfo = nan(length(headerSel),1);
                            %                             for ic=1:length(headerSel)
                            %                                 IndsColInfo(ic) = find(strcmp(ShoulderCheckInfo.header,headerSel{ic}));
                            %                             end
                            %                             DatSel = ShoulderCheckInfo.data(iData,IndsColInfo);
                            %                             if sum(DatSel) == 0
                            
                            % einde trial als R frame een bepaalde
                            % hoek over gaat
                            % get index turned                           
                            
                            if isfield(Events,'ShoulderCheck') && ~isempty(Events.ShoulderCheck)
                                t0 = Events.ShoulderCheck(1) - 0.5;
                                tend = Events.ShoulderCheck(2) + 0.5;
                            else
                                Rframe = Phases.Frame.DualTask.R;
                                tframe = Phases.Frame.DualTask.t;
                                [eulframe] = GetEulAngles_ShoulderCheck(Rframe);
                                t0 = tframe(1) + 3;
                                iTurned = find(eulframe(:,1) > 1,1,'first');
                                if isempty(iTurned)
                                    tend = tframe(end); % just select end of file (indicates that trigger pulse was too early
                                    disp(['possible error in file: ' filename ]);
                                    BoolErrorFlag = 1;
                                else
                                    tend = tframe(iTurned)-3; % 3 seconden hiervoor
                                end
                            end
                            t = Phases.SteerAngle.DualTask.t;
                            q = Phases.SteerAngle.DualTask.qSteer(:,1); % steer angle aroud x-axis
                            iSel = find(t>t0 & t<tend);
                            qVar = var(q(iSel));
                            qVarDeg = qVar*180/pi;
                            % trim unrealistic high variance in steering
                            % angle
                            if qVarDeg >5
                                disp(['possible error in file: ' filename ' remove this file from the analysis']);
                                qVarDeg = NaN;
                            end
                            % store the ROM in the datamatrix
                            DataMatrix(ct,1) = s;
                            DataMatrix(ct,2) = f;
                            DataMatrix(ct,3) = i;
                            DataMatrix(ct,4) = qVarDeg;
                            DataMatrix(ct,5) = BoolEld;
                            DataMatrix(ct,6) = BoolErrorFlag;
                            ct = ct+1;
                        end
                        %                         else
                        %                             disp(['subject ' num2str(s) ' removed from analysis']);
                        %                         end
                    end
                    clear Phases GUIvar Events header
                end
            end
        end
        disp(['Subject ' num2str(s) ' / ' num2str(nPP)]);
    end
    DataMatrix(ct:end,:) = [];
    % save the datamatrix
    if ~isfolder(fullfile(DataPath,'Outcomes'))
        mkdir(fullfile(DataPath,'Outcomes'));
    end
    save(fullfile(DataPath,'Outcomes','ShouldCheck_SteerAngle.mat'),'DataMatrix','header_DataMatrix');
    diary off
else
    load(fullfile(DataPath,'Outcomes','ShouldCheck_SteerAngle.mat'),'DataMatrix','header_DataMatrix');
end

%% Plot figure

CYoung = [91 91 213]./255;%  color for young (see https://www.rapidtables.com/web/color/RGB_Color.html)
CEld = [179 77 40]./255; % color for elderly (see https://www.rapidtables.com/web/color/RGB_Color.html)
mk  = 3;

figure();
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSel,4),CEld,mk); hold on;