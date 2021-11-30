%% Bar Plots ROM and Steering angle

% Figure with IMU outcomes during cycling parcours


% Datapath = 'S:\Data\fietsproef\Data';
DataPath  = 'E:\fietsproef\Data';
addpath 'C:\Users\r0721298\Documents\software\SafeCycling\Examples'
% Steering = load(fullfile(DataPath,'Outcomes','ShouldCheck_SteerAngle.mat'),'DataMatrix','header_DataMatrix');
SensorOr = load(fullfile(DataPath,'Outcomes','ShouldCheckROM.mat'),'DataMatrix','header_DataMatrix');

figPath = fullfile(pwd,'FigsPaper');

%% FIgure steering angle
diary('FigureCorrSteeringAngle.txt');


CYoung = [0 0 1];
CEld = [1 0 0];
mk = 3;

% plot figure
for speed_ID = 1:2
    DataMatrix = SensorOr.DataMatrix;
    h = figure(speed_ID)
    set(h,'Position',[113   394   765   623]);
    subplot(1,1,1);
    iSelY = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == speed_ID & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
    PlotBar(1,DataMatrix(iSelY,10),CYoung,mk); hold on;
    iSelE = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == speed_ID & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
    PlotBar(2,DataMatrix(iSelE,10),CEld,mk); hold on;
    set(gca,'XTick',1:2);
    set(gca,'XTickLabel',{'Young','Older'});
    
    % test normality
    % [Wilk(1).HY, Wilk(1).pValueY, Wilk(1).WY] = swtest(DataMatrix(iSelY,10), 0.05);
    % [Wilk(1).HE, Wilk(1).pValueE, Wilk(1).WE] = swtest(DataMatrix(iSelE,10), 0.05);
    [Wilk_young(speed_ID).HY, Wilk_young(speed_ID).pValueY, Wilk_young(speed_ID).WY] = swtest(DataMatrix(iSelY,10), 0.05); %normality young
    [Wilk_elderly(speed_ID).HE, Wilk_elderly(speed_ID).pValueE, Wilk_elderly(speed_ID).WE] = swtest(DataMatrix(iSelE,10), 0.05);  %normality elderly
    
    %ttest ond data
    if Wilk_young(speed_ID).HY == 0 && Wilk_elderly(speed_ID).HE ==0
        [pairedttest,p,ci,stats] = ttest2(DataMatrix(iSelY,10),DataMatrix(iSelE,10),0.05); %ttest2 young vs elderly %one time for normal, one time for slow cond
        p_value(speed_ID) = p;
        header_p_value = {'Normal', 'Slow'};
    else
        [p,h,stats] = ranksum(DataMatrix(iSelY,10),DataMatrix(iSelE,10),'alpha',0.05); %wilcoxon sum rank test because no-normality assumption
        p_value(speed_ID) = p;
        header_p_value = {'Normal', 'Slow'};
    end
    disp('Correlation steering angle and torso orientation ')
    disp(['number of young subjects ' , num2str(sum(~isnan(DataMatrix(iSelY,10))))]);
    disp(['number of older subjects ' , num2str(sum(~isnan(DataMatrix(iSelE,10))))]);
    disp(' ');
    title(['corr. steering angle and frame or: p = ' num2str(p)]);
    if speed_ID == 1
        sgtitle('Normal condition')
    else
        sgtitle('Slow condition')
    end
    set(gca,'FontSize',12);
    set(gca,'LineWidth',1.5);
    ylabel('Angle [deg]');
end
