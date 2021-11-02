%% Figure 3

% summary figure with results

% Figure with summary results sensor orienatations




Datapath = 'S:\Data\fietsproef\Data';
% 
% Steering = load(fullfile(DataPath,'Outcomes','ShouldCheck_SteerAngle.mat'),'DataMatrix','header_DataMatrix');
% SensorOr = load(fullfile(DataPath,'Outcomes','ShouldCheckROM.mat'),'DataMatrix','header_DataMatrix');


% get the average angles
DataMatrix = SensorOr.DataMatrix;
iCol = [4 7 8];
TitleSel = {'ROM Frame-C7','ROM Frame-Pelvis','ROM Pelvis-Trunk'};

qSel =[110 150];
% qSel = nan(3,2);
% 
% for i=1:3
%     subplot(2,2,i+1);
%     
%     iSelY = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
%     qSel(i,nanmean(DataMatrix(iSelY,iCol(i))));
%     
%     iSelE = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
%     qSel(i,nanmean(DataMatrix(iSelE,iCol(i))));
% end


figure();

plot([-1 0 1],[sind(-qSel(1,2)/2) 0 sind(qSel(1,2)/2)])
