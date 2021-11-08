%% Example on how to analyse data
%--------------------------------

clear all; close all; clc;

DataPath  = 'E:\fietsproef\Data';
FigPath = 'E:\fietsproef\Data\Figures\ShoulderCheck';
nPP = 81;
Folders = {'Classic'};
OrderMeas = {'normal'};
SensorLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};

% load the info of the folders
load(fullfile(DataPath,'MatData','ppInfo.mat'),'ppYoung','ppEld');

% flow control
ComputeDataMatrix = true; % Run part to compute datamatrix (or load saved .mat file)
BoolPlot2 = false; % individual plot for each subject with the input data to copumpute variance

% tresholds
threshold_drift = 0.3; % 0.3 radians in this task

figPath = 'E:\fietsproef\Data\ResultsFig\ShoulderCheck\ROM';

%% Read the excel table with information on the task

datapath = 'E:\fietsproef\';
FileYoung = fullfile(datapath,'opmerkingen proefpersonen.xlsx');
[ShoulderCheckInfo] = GetShoulderCheckInfo(FileYoung);

ShoulderCheckInfo.pp = [ShoulderCheckInfo.ppIDYoung; ShoulderCheckInfo.ppIDOld];
ShoulderCheckInfo.data = [ShoulderCheckInfo.DatYoung; ShoulderCheckInfo.DatOlder];
ShoulderCheckInfo.header = ShoulderCheckInfo.HeadersOlder;


%% Get the Datamatrix
if ComputeDataMatrix
    DataMatrix = nan(100*3*2,9); % pre allocat matrix with all the data
    header_DataMatrix =  {'s-ID','bike-ID','Speed-ID','ROM-FrameTorso','BoolElderly','Error','ROM-FramePelvis','ROM-PelvisTorso','SteeringAngle','CorrSteerTorso'}; % header for the datamatrix
    diary('LogExample_ShoulderCheck.txt');
    ct = 1;
    for s = 1:nPP
        ppPath = ['pp_' num2str(s)];
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
                            % get the euler angles
                            % check if task was performed according to
                            % instructions
                            iData = find(ShoulderCheckInfo.pp== s);
                            if strcmp(Folders{f},'Classic')
                                if strcmp(OrderMeas{i},'normal')
                                    headerSel = {'KEGEL NIET GEZIEN-normal-classic',...
                                        'VOET GROND-normal-classic'};
                                end
                            elseif strcmp(Folders{f},'EBike')
                                if strcmp(OrderMeas{i},'normal')
                                    headerSel = {'KEGEL NIET GEZIEN-normal-ebike',...
                                        'VOET GROND-normal-ebike'};
                                end
                            end
                            % select colIndices
                            IndsColInfo = nan(length(headerSel),1);
                            for ic=1:length(headerSel)
                                IndsColInfo(ic) = find(strcmp(ShoulderCheckInfo.header,headerSel{ic}));
                            end
                            DatSel = ShoulderCheckInfo.data(iData,IndsColInfo);
                            if sum(DatSel) == 0
                                % we don't use the first 3 and last 5 seconds in the
                                % movement
                                Rtorso = Phases.Trunk.DualTask.R;
                                ttorso = Phases.Trunk.DualTask.t;
                                Rframe = Phases.Frame.DualTask.R;
                                tframe = Phases.Frame.DualTask.t;
                                
                                
                                if ~isfield(Phases,'Pelvis')
                                    Rpelvis = [];
                                    tpelvis = [];
                                else
                                    Rpelvis = Phases.Pelvis.DualTask.R;
                                    tpelvis = Phases.Pelvis.DualTask.t;
                                end
                                BoolPelvisError = false;
                                if isempty(Rpelvis)
                                    BoolPelvisError = true;
                                end
                                
                                if (isfield(Events,'ShoulderCheck') && ~isempty(Events.ShoulderCheck) &&   ~any(isnan(Events.ShoulderCheck)))
                                    % get the euler angles
                                    [eulTorso] = GetEulAngles_ShoulderCheck(Rtorso);
                                    if ~BoolPelvisError
                                        [eulpelvis] = GetEulAngles_ShoulderCheck(Rpelvis);
                                    end
                                    [eulframe] = GetEulAngles_ShoulderCheck(Rframe);
                                    % interpolate eueler angles
                                    eulTorso_int = interp1(ttorso,eulTorso,tframe);
                                    if ~BoolPelvisError
                                        eulPelvis_int = interp1(tpelvis,eulpelvis,tframe);
                                    end
                                    % relative angles
                                    Q_TorsoFrame = eulTorso_int - eulframe;
                                    if ~BoolPelvisError
                                        Q_PelvisFrame = eulPelvis_int - eulframe;
                                        Q_TorsoPelvis = eulTorso_int -eulPelvis_int;
                                    end
                                    % event detection based on GUI
                                    % information
                                    
                                    % rotation of torso w.r.t. to
                                    % frame
                                    t0 = Events.ShoulderCheck(1) - 0.5;
                                    tend = Events.ShoulderCheck(2) + 0.5;
                                    iSel = find(ttorso>t0 & ttorso<tend);
                                    [MinQ,iMin] = min(Q_TorsoFrame(iSel,1));
                                    [MaxQ,iMax] = max(Q_TorsoFrame(iSel,1));
                                    ROM = (MaxQ - MinQ)*180/pi;
                                    if isempty(ROM)
                                        ROM = NaN;
                                    end
                                    
                                    % steering angle
                                    t = Phases.SteerAngle.DualTask.t;
                                    iSelSteer = find(t>t0 & t<tend);
                                    q = Phases.SteerAngle.DualTask.qSteer(:,1); % steer angle aroud x-axis
                                    qVarDeg = std(q(iSelSteer)*180/pi);
                                    if qVarDeg >20
                                        disp(['possible error in file: ' filename ' remove this file from the analysis']);
                                        qVarDeg = NaN;
                                    end
                                    
                                    % correlation between steering angle
                                    % and orientation of the torso
                                    eulTorso_intSteer = interp1(ttorso,eulTorso(:,1),Phases.SteerAngle.DualTask.t(iSelSteer))';
                                    qSteer = q(iSelSteer,1);
                                    rho = corr(eulTorso_intSteer,qSteer);
                                   
                                    
                                    if isfield(GUIvar,'Shoulder_Drift') && ~GUIvar.Shoulder_Drift && ~BoolPelvisError
                                        [MinQ2,iMin] = nanmin(Q_PelvisFrame(iSel,1));
                                        [MaxQ2,iMax] = nanmax(Q_PelvisFrame(iSel,1));
                                        ROM2 = (MaxQ2 - MinQ2)*180/pi;
                                        [MinQ3,iMin] = min(Q_TorsoPelvis(iSel,1));
                                        [MaxQ3,iMax] = max(Q_TorsoPelvis(iSel,1));
                                        ROM3 = (MaxQ3 - MinQ3)*180/pi;
                                    else
                                        ROM2 = NaN;
                                        ROM3 = NaN;
                                    end
                                else
                                    ROM = NaN;
                                    ROM2 = NaN;
                                    ROM3 = NaN;
                                    qVarDeg = NaN;
                                    rho = NaN;
                                end
                                % store the ROM in the datamatrix
                                DataMatrix(ct,1) = s;
                                DataMatrix(ct,2) = f;
                                DataMatrix(ct,3) = i;
                                DataMatrix(ct,4) =  ROM ;
                                DataMatrix(ct,5) = BoolEld;
                                DataMatrix(ct,6) = BoolErrorFlag;
                                DataMatrix(ct,7) = ROM2;
                                DataMatrix(ct,8) = ROM3;
                                DataMatrix(ct,9) = qVarDeg;
                                DataMatrix(ct,10) = rho;
                                ct = ct+1;
                            end
                        end
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
    save(fullfile(DataPath,'Outcomes','ShouldCheckROM.mat'),'DataMatrix','header_DataMatrix');
    diary off
else
    load(fullfile(DataPath,'Outcomes','ShouldCheckROM.mat'),'DataMatrix','header_DataMatrix');
end

%% Visual comparison of variance in steer angle

% Tip: I would always use the same colors for all graphs in your thesis. So
% pick them carefully :).
CYoung = [91 91 213]./255;%  color for young (see https://www.rapidtables.com/web/color/RGB_Color.html)
CEld = [179 77 40]./255; % color for elderly (see https://www.rapidtables.com/web/color/RGB_Color.html)
mk  = 3;

figure();
subplot(1,2,1)
% note fore now without errors possible DataMatrix(:,6) == 0
% normal bike - normal speed  [young Old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSel,4),CEld,mk); hold on;

% normal bike - slow speed - [young old
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(4,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(5,DataMatrix(iSel,4),CEld,mk); hold on;

% normal bike - dual task - [young old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(7,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(8,DataMatrix(iSel,4),CEld,mk); hold on;

% ylabel('Variance steering angle [deg]');
set(gca,'XTick',[1.5 4.5 7.5]);
set(gca,'XTickLabel',{'Normal','Slow','DualTask'});
title('Normal Bike');
% set(gca,'YLim',[0 4]); % adapt this based on maxiaml values (make sure you don't exclude datapoints)
set(gca,'Box','off')
set(gca,'FontSize',10);
set(gca,'LineWidth',1);
ylabel('ROM C7 - Frame [deg]');

subplot(1,2,2)
% note fore now without errors possible DataMatrix(:,6) == 0
% normal bike - normal speed  [young Old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSel,4),CEld,mk); hold on;

% normal bike - slow speed - [young old
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(4,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(5,DataMatrix(iSel,4),CEld,mk); hold on;

% normal bike - dual task - [young old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(7,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(8,DataMatrix(iSel,4),CEld,mk); hold on;

set(gca,'XTick',[1.5 4.5 7.5]);
set(gca,'XTickLabel',{'Normal','Slow','DualTask'});
title('E-Bike');
% set(gca,'YLim',[0 4]);% adapt this based on maxiaml values (make sure you don't exclude datapoints)
set(gca,'Box','off');
legend('Young','Old');
ax = gca;
l1 = ax.Children(4);
l2 = ax.Children(2);
legend([l1 l2],{'Young','Old'});
set(gca,'FontSize',10);
set(gca,'LineWidth',1);
ylabel('ROM C7 - Frame [deg]');

set(gcf,'Position',[1044         565        1172         363]);
saveas(gcf,fullfile(figPath,'ROM_Frame_C7_ShoulderCheck.svg'),'svg');
saveas(gcf,fullfile(figPath,'ROM_Frame_C7_ShoulderCheck.png'),'png');


%% Visual comparison of variance in steer angle

% Tip: I would always use the same colors for all graphs in your thesis. So
% pick them carefully :).
CYoung = [91 91 213]./255;%  color for young (see https://www.rapidtables.com/web/color/RGB_Color.html)
CEld = [179 77 40]./255; % color for elderly (see https://www.rapidtables.com/web/color/RGB_Color.html)
mk  = 3;

figure('Name','FramePelvis');
subplot(1,2,1)
% note fore now without errors possible DataMatrix(:,6) == 0
% normal bike - normal speed  [young Old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSel,7),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSel,7),CEld,mk); hold on;

% normal bike - slow speed - [young old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(4,DataMatrix(iSel,7),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(5,DataMatrix(iSel,7),CEld,mk); hold on;

% normal bike - dual task - [young old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(7,DataMatrix(iSel,7),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(8,DataMatrix(iSel,7),CEld,mk); hold on;

% ylabel('Variance steering angle [deg]');
set(gca,'XTick',[1.5 4.5 7.5]);
set(gca,'XTickLabel',{'Normal','Slow','DualTask'});
title('Normal Bike');
% set(gca,'YLim',[0 4]); % adapt this based on maxiaml values (make sure you don't exclude datapoints)
set(gca,'Box','off')
set(gca,'FontSize',10);
set(gca,'LineWidth',1);
ylabel('ROM Pelvis - Frame [deg]');

subplot(1,2,2)
% note fore now without errors possible DataMatrix(:,6) == 0
% normal bike - normal speed  [young Old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSel,7),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSel,7),CEld,mk); hold on;

% normal bike - slow speed - [young old
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(4,DataMatrix(iSel,7),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(5,DataMatrix(iSel,7),CEld,mk); hold on;

% normal bike - dual task - [young old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(7,DataMatrix(iSel,7),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(8,DataMatrix(iSel,7),CEld,mk); hold on;

set(gca,'XTick',[1.5 4.5 7.5]);
set(gca,'XTickLabel',{'Normal','Slow','DualTask'});
title('E-Bike');
% set(gca,'YLim',[0 4]);% adapt this based on maxiaml values (make sure you don't exclude datapoints)
set(gca,'Box','off');
legend('Young','Old');
ax = gca;
l1 = ax.Children(4);
l2 = ax.Children(2);
legend([l1 l2],{'Young','Old'});
set(gca,'FontSize',10);
set(gca,'LineWidth',1);
ylabel('ROM Pelvis - Frame [deg]');

set(gcf,'Position',[1044         565        1172         363]);
saveas(gcf,fullfile(figPath,'ROM_Frame_Pelvis_ShoulderCheck.svg'),'svg');
saveas(gcf,fullfile(figPath,'ROM_Frame_Pelvis_ShoulderCheck.png'),'png');


%% Visual comparison of variance in steer angle

% Tip: I would always use the same colors for all graphs in your thesis. So
% pick them carefully :).
CYoung = [91 91 213]./255;%  color for young (see https://www.rapidtables.com/web/color/RGB_Color.html)
CEld = [179 77 40]./255; % color for elderly (see https://www.rapidtables.com/web/color/RGB_Color.html)
mk  = 3;

figure('Name','PelvisTorso');
subplot(1,2,1)
% note fore now without errors possible DataMatrix(:,6) == 0
% normal bike - normal speed  [young Old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSel,8),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSel,8),CEld,mk); hold on;

% normal bike - slow speed - [young old
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(4,DataMatrix(iSel,8),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(5,DataMatrix(iSel,8),CEld,mk); hold on;

% normal bike - dual task - [young old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(7,DataMatrix(iSel,8),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(8,DataMatrix(iSel,8),CEld,mk); hold on;

% ylabel('Variance steering angle [deg]');
set(gca,'XTick',[1.5 4.5 7.5]);
set(gca,'XTickLabel',{'Normal','Slow','DualTask'});
title('Normal Bike');
% set(gca,'YLim',[0 4]); % adapt this based on maxiaml values (make sure you don't exclude datapoints)
set(gca,'Box','off')
set(gca,'FontSize',10);
set(gca,'LineWidth',1);
ylabel('ROM C7 - Pelvis [deg]');

subplot(1,2,2)
% note fore now without errors possible DataMatrix(:,6) == 0
% normal bike - normal speed  [young Old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSel,8),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSel,8),CEld,mk); hold on;

% normal bike - slow speed - [young old
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(4,DataMatrix(iSel,8),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(5,DataMatrix(iSel,8),CEld,mk); hold on;

% normal bike - dual task - [young old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(7,DataMatrix(iSel,8),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(8,DataMatrix(iSel,8),CEld,mk); hold on;

set(gca,'XTick',[1.5 4.5 7.5]);
set(gca,'XTickLabel',{'Normal','Slow','DualTask'});
title('E-Bike');
% set(gca,'YLim',[0 4]);% adapt this based on maxiaml values (make sure you don't exclude datapoints)
set(gca,'Box','off');
legend('Young','Old');
ax = gca;
l1 = ax.Children(4);
l2 = ax.Children(2);
legend([l1 l2],{'Young','Old'});
set(gca,'FontSize',10);
set(gca,'LineWidth',1);
ylabel('ROM C7 - Pelvis [deg]');

set(gcf,'Position',[1044         565        1172         363]);
saveas(gcf,fullfile(figPath,'ROM_Pelvis_Torso_ShoulderCheck.svg'),'svg');
saveas(gcf,fullfile(figPath,'ROM_Pelvis_Torso_ShoulderCheck.png'),'png');

%%
%paired ttest for all data analyzed in the young and older subjects (Note
%that this includes data of cycling at differents speeds, duals task and
%different bikes).
iGender = strcmp(header_DataMatrix,'BoolElderly');
iYoung = DataMatrix(:,iGender) == 0 ;
iOld = DataMatrix(:,iGender) == 1 ;

[pairedttest,p,ci,stats] = ttest2(DataMatrix(iYoung,4),DataMatrix(iOld,4),0.05);
[pairedttest,p,ci,stats] = ttest2(DataMatrix(iYoung,8),DataMatrix(iOld,8),0.05);

[pairedttest,p,ci,stats] = ttest(DataMatrix(:,5),DataMatrix(:,3),0.05);