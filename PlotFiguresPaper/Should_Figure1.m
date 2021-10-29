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
figPathRaw = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Software\figs\tempFigs';


%% select subject
s = 10; % 37 uit zadel , 10 niet uit zadel
f = 1;
i = 1;



%% Get the Datamatrix


ppPath = ['pp_' num2str(s)];
% detect if this is a young or an older subject
BoolEld = any(ppEld ==s);
BoolYoung = any(ppYoung ==s);
% load the data
OutName = [OrderMeas{i} '_data.mat'];
OutPathMat = fullfile(DataPath,'MatData',ppPath,Folders{f});
filename = fullfile(OutPathMat,OutName);
load(filename);
% we don't use the first 3 and last 5 seconds in the
% movement
Rtorso = Phases.Trunk.DualTask.R;
ttorso = Phases.Trunk.DualTask.t;
Rpelvis = Phases.Pelvis.DualTask.R;
tpelvis = Phases.Pelvis.DualTask.t;
Rframe = Phases.Frame.DualTask.R;
tframe = Phases.Frame.DualTask.t;
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



%% Plot figure
figure();

[CPelv, CTors, CFrame] = GetColorsSensorLocation();
lw = 2;


% sensor orientations
plot(tpelvis-t0,eulpelvis(:,1),'Color',CPelv,'LineWidth',lw); hold on;
plot(ttorso-t0,eulTorso(:,1),'Color',CTors,'LineWidth',lw);
plot(tframe-t0,eulframe(:,1),'Color',CFrame,'LineWidth',lw);

% relative angles
vline(t0-t0,'k');
vline(tend-t0,'k');
title(['subject ' num2str(s) ' ' Folders{f} ' ' OrderMeas{i}]);
ylabel('orientations');
set(gca,'LineWidth',1.5);
set(gca,'FontSize',12);
% set(gca,'XLim',[-3 4.5]);
set(gca,'YLim',[-1.5 2]);

delete_box
%%

figure();
plot(tframe,Q_TorsoFrame(:,1),'k','LineWidth',2); hold on;
plot(tframe,Q_PelvisFrame(:,1),'b'); hold on;
plot(tframe,Q_TorsoPelvis(:,1),'r'); hold on;
legend('Torso-frame','pelvis-frame','torso-pelvis');
vline(t0,'k');
vline(tend,'k');
hline(MaxQ,'k');
hline(MinQ,'k');
set(gca,'YLim',[-2 2]);
ylabel('Relative angles [deg]');
delete_box

figure();
plot(ttorso,Phases.Trunk.DualTask.QdWorld(:,3),'r'); hold on; hold on;
plot(tframe,Phases.Frame.DualTask.QdWorld(:,3),'k')
plot(tpelvis,Phases.Pelvis.DualTask.QdWorld(:,3),'b')
vline(t0,'k');
vline(tend,'k');
delete_box
xlabel('Time [s]');
ylabel('angular velocity');
legend('pelvis','torso','frame');
