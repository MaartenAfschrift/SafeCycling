%% Bar Plots ROM and Steering angle

% Figure with IMU outcomes during cycling parcours


Datapath = 'S:\Data\fietsproef\Data';

% Steering = load(fullfile(DataPath,'Outcomes','ShouldCheck_SteerAngle.mat'),'DataMatrix','header_DataMatrix');
SensorOr = load(fullfile(DataPath,'Outcomes','ShouldCheckROM.mat'),'DataMatrix','header_DataMatrix');

figPath = fullfile(pwd,'FigsPaper');

%% FIgure steering angle
diary('Figure2_Log.txt');    
h = figure();
set(h,'Position',[113   394   765   623]);

% plot figure
DataMatrix = SensorOr.DataMatrix;
subplot(2,2,1);
iSelY = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSelY,9),CYoung,mk); hold on;
iSelE = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSelE,9),CEld,mk); hold on;
set(gca,'XTick',1:2);
set(gca,'XTickLabel',{'Young','Older'});

%ttest ond data
[pairedttest,p,ci,stats] = ttest2(DataMatrix(iSelY,9),DataMatrix(iSelE,9),0.05);
disp('steering angle ')
disp(['number of young subjects ' , num2str(sum(~isnan(DataMatrix(iSelY,9))))]);
disp(['number of older subjects ' , num2str(sum(~isnan(DataMatrix(iSelE,9))))]);
disp(' ');
title(['Steering angle: p = ' num2str(p)]);
set(gca,'FontSize',12);
set(gca,'LineWidth',1.5);
ylabel('Angle [deg]');



DataMatrix = SensorOr.DataMatrix;
iCol = [4 7 8];
TitleSel = {'ROM Frame-C7','ROM Frame-Pelvis','ROM Pelvis-Trunk'};

for i=1:3
    subplot(2,2,i+1);
    
    iSelY = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
    PlotBar(1,DataMatrix(iSelY,iCol(i)),CYoung,mk); hold on;
    iSelE = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
    PlotBar(2,DataMatrix(iSelE,iCol(i)),CEld,mk); hold on;
    set(gca,'XTick',1:2);
    set(gca,'XTickLabel',{'Young','Older'});
    

    
    [pairedttest,p,ci,stats] = ttest2(DataMatrix(iSelY,iCol(i)),DataMatrix(iSelE,iCol(i)),0.05);
    disp(TitleSel{i});
    disp(['number of young subjects ' , num2str(sum(~isnan(DataMatrix(iSelY,iCol(i)))))]);
    disp(['number of older subjects ' , num2str(sum(~isnan(DataMatrix(iSelE,iCol(i)))))]);
    disp(' ');
    title([TitleSel{i} ': p = ' num2str(p)]);
    set(gca,'FontSize',12);
    set(gca,'LineWidth',1.5);
    ylabel('ROM [deg]');
    
end

% delete box from figure
delete_box

% save the figure
saveas(gcf,fullfile(figPath,'Figure2.svg'),'svg');
saveas(gcf,fullfile(figPath,'Figure2.png'),'png');
diary off
