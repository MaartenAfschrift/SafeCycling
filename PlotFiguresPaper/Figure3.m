%% Figure 3

% path information

%ExcelFile = 'C:\Users\u0088756\Documents\FWO\Data\fietsproject\opmerkingen proefpersonen.xlsx';
ExcelFile = 'E:\fietsproef\opmerkingen proefpersonen.xlsx';
DatFile = 'C:\Users\u0088756\Documents\FWO\Data\fietsproject\ShouldCheckROM.mat';
addpath 'C:\Users\r0721298\Documents\software\SafeCycling\Functions'
figPath = fullfile(pwd,'FigsPaper');

% read the excel file with quantitative information
[ShoulderCheckInfo] = GetShoulderCheckInfo(ExcelFile);
figure();

subplot(1,2,1)
pie([10 0 0 0 0]);

subplot(1,2,2)
Zadel = sum(ShoulderCheckInfo.DatOlder(:,1)==1 & ShoulderCheckInfo.DatOlder(:,3)~=1);
Kegel = sum(ShoulderCheckInfo.DatOlder(:,2)==1 & ShoulderCheckInfo.DatOlder(:,3)~=1);
Voet = sum(ShoulderCheckInfo.DatOlder(:,3)==1);
BuitLijn = sum(ShoulderCheckInfo.DatOlder(:,4)==1 & ShoulderCheckInfo.DatOlder(:,3)~=1);
AllesOK = sum(sum(ShoulderCheckInfo.DatOlder(:,1:4),2) == 0);
pie([AllesOK BuitLijn Voet Kegel Zadel]);
labels = {'Alles OK','Buiten de lijn','Voet aan de grond', 'Kegel geraakt', 'Uit zadel gekomen'};
legend(labels,'Location','southoutside','Orientation','horizontal')

set(gcf,'Position',[634   360   794   360]);
saveas(gcf,fullfile(figPath,'Figure3_pie.svg'),'svg');
