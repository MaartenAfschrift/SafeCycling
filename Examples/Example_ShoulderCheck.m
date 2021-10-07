%% Example on how to analyse data
%--------------------------------

clear all; close all; clc;

DataPath  = 'S:\Data\fietsproef\Data';
FigPath = 'S:\Data\fietsproef\Data\Figures\ShoulderCheck';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas = {'normal','slow','DualTask','extra','extra2','extra3'};
SensorLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};

% here we want to compute the variation in steer angle during the "narrow
% lane" task (i.e. first task cycling parcours
ParcousSelected = 'small';

% load the info of the folders
load(fullfile(DataPath,'MatData','ppInfo.mat'),'ppYoung','ppEld');


% flow control
ComputeDataMatrix = true; % Run part to compute datamatrix (or load saved .mat file)
BoolPlot2 = false; % individual plot for each subject with the input data to copumpute variance

% tresholds
threshold_drift = 0.3; % 0.3 radians in this task

figPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Software\figs';

%% Get the Datamatrix
if ComputeDataMatrix
    DataMatrix = nan(100*3*2,8); % pre allocat matrix with all the data
    header_DataMatrix =  {'s-ID','bike-ID','Speed-ID','ROM-FrameTorso','BoolElderly','Error','ROM-FramePelvis','ROM-PelvisTorso'}; % header for the datamatrix
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
            for i =1:3
                % load the data
                OutName = [OrderMeas{i} '_data.mat'];
                OutPathMat = fullfile(DataPath,'MatData',ppPath,Folders{f});
                filename = fullfile(OutPathMat,OutName);
                if exist(filename,'file')
                    load(filename,'Phases','header');
                    
                    if exist('Phases','var')
                        BoolErrorFlag = 0;
                        % get the variance in steer angle
                        if isfield(Phases,'SteerAngle') && ~isempty(Phases.SteerAngle.small.t)
                            
                            
                            % event detection for the dual task
                            
                            
                            % get the euler angles
                            if isfield(Phases,'Trunk') && isfield(Phases,'Pelvis') && isfield(Phases,'Frame')
                                
                                
                                % event detection based on angular velocity
                                % around z-axis
                                
                                % we don't use the first 3 and last 5 seconds in the
                                % movement
                                Rtorso = Phases.Trunk.DualTask.R;
                                ttorso = Phases.Trunk.DualTask.t;
                                Rpelvis = Phases.Pelvis.DualTask.R;
                                tpelvis = Phases.Pelvis.DualTask.t;
                                Rframe = Phases.Frame.DualTask.R;
                                tframe = Phases.Frame.DualTask.t;
                                if ~isempty(Rpelvis)
                                    % get the euler angles
                                    [eulTorso] = GetEulAngles_ShoulderCheck(Rtorso);
                                    [eulpelvis] = GetEulAngles_ShoulderCheck(Rpelvis);
                                    [eulframe] = GetEulAngles_ShoulderCheck(Rframe);
                                    % interpolate eueler angles
                                    eulTorso_int = interp1(ttorso,eulTorso,tframe);
                                    eulPelvis_int = interp1(tpelvis,eulpelvis,tframe);
                                    % relative angles
                                    Q_TorsoFrame = eulTorso_int - eulframe;
                                    Q_PelvisFrame = eulPelvis_int - eulframe;
                                    Q_TorsoPelvis = eulTorso_int -eulPelvis_int;
                                    
                                    % einde trial als R frame een bepaalde
                                    % hoek over gaat
                                    % get index turned
                                    t0 = ttorso(1) + 3;
                                    iTurned = find(eulframe(:,1) > 1,1,'first');
                                    if isempty(iTurned)
                                        tend = ttorso(end); % just select end of file (indicates that trigger pulse was too early
                                        disp(['possible error in file: ' filename ]);
                                        BoolErrorFlag = 1;
                                    else
                                        tend = ttorso(iTurned)-3; % 3 seconden hiervoor
                                    end
                                    iSel = find(ttorso>t0 & ttorso<tend);
                                    [MinQ,iMin] = min(Q_TorsoFrame(iSel,1));
                                    [MaxQ,iMax] = max(Q_TorsoFrame(iSel,1));
                                    ROM = (MaxQ - MinQ)*180/pi;
                                    
                                    [MinQ2,iMin] = min(Q_PelvisFrame(iSel,1));
                                    [MaxQ2,iMax] = max(Q_PelvisFrame(iSel,1));
                                    ROM2 = (MaxQ2 - MinQ2)*180/pi;
                                    
                                    [MinQ3,iMin] = min(Q_TorsoPelvis(iSel,1));
                                    [MaxQ3,iMax] = max(Q_TorsoPelvis(iSel,1));
                                    ROM3 = (MaxQ3 - MinQ3)*180/pi;
                                    
                                    if ~isempty(ROM)
                                        
                                        % store the ROM in the datamatrix
                                        DataMatrix(ct,1) = s;
                                        DataMatrix(ct,2) = f;
                                        DataMatrix(ct,3) = i;
                                        DataMatrix(ct,4) =  ROM ;
                                        DataMatrix(ct,5) = BoolEld;
                                        DataMatrix(ct,6) = BoolErrorFlag;
                                        DataMatrix(ct,7) = ROM2;
                                        DataMatrix(ct,8) = ROM3;
                                        ct = ct+1;  
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        disp(['Subject ' num2str(s) ' / ' num2str(nPP)]);
    end
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

% normal bike - slow speed - [young old
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