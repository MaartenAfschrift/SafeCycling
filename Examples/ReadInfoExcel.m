%% Read excel file to determine is subjects is young or old

datapath = 'E:\Data\Fietsproef\RawData';
FileYoung = fullfile(datapath,'opmerkingen proefpersonen.xlsx');

% get info of subject
[Ydat,Yheaders] = xlsread(FileYoung,'INFO-Jong');
[Edat,Eheaders] = xlsread(FileYoung,'INFO-Oud');

%% get the folder names of the young and older
iPP_Y = strcmp(Yheaders(3,:),'PP');
iPP_E = strcmp(Eheaders(3,:),'PP');

ppYoung = Ydat(:,find(iPP_Y));
ppEld = Edat(:,find(iPP_E));

save(fullfile(datapath,'ppInfo.mat'),'ppYoung','ppEld');
