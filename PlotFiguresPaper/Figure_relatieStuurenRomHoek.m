%% Bar Plots ROM and Steering angle

% Figure with IMU outcomes during cycling parcours


% Datapath = 'S:\Data\fietsproef\Data';
DataPath  = 'E:\fietsproef\Data';

% Steering = load(fullfile(DataPath,'Outcomes','ShouldCheck_SteerAngle.mat'),'DataMatrix','header_DataMatrix');
SensorOr = load(fullfile(DataPath,'Outcomes','ShouldCheckROM.mat'),'DataMatrix','header_DataMatrix');

figPath = fullfile(pwd,'FigsPaper');

%% FIgure steering angle
diary('Figure2_Log.txt');    
h = figure();
set(h,'Position',[113   394   765   623]);

CYoung = [0 0 1];
CEld = [1 0 0];
mk = 5;

% plot figure
DataMatrix = SensorOr.DataMatrix;
subplot(2,2,1);
iSelY = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
iSelE = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
qSteerYoung = DataMatrix(iSelY,9);
qSteerEld = DataMatrix(iSelE,9);
ROMtorsoYoung = DataMatrix(iSelY,4);
ROMtorsoEld = DataMatrix(iSelE,4);

figure();
plot(qSteerYoung,ROMtorsoYoung,'o','Color',CYoung,'MarkerFaceColor',CYoung,'MarkerSize',mk); hold on;
plot(qSteerEld,ROMtorsoEld,'o','Color',CEld,'MarkerFaceColor',CEld,'MarkerSize',mk); hold on;
xlabel('variance steering angle');
ylabel('ROM torso-frame');
set(gca,'FontSize',11);
set(gca,'LineWidth',1.5);
set(gca,'box','off');
legend('young','older');
