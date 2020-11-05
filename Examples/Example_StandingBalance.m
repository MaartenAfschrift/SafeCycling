

%% ComineData StandingBalance

clear all; close all; clc;
MainPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Software';
datapath = 'E:\Data\Fietsproef\RawData';
OutPath  = 'E:\Data\Fietsproef\MatData';

StringLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
OrderMeas       = {'StandOpen1','StandOpen2','StandClosed1','StandClosed2',...
    'TandemOpen1','TandemOpen2','TandemClosed1','TandemClosed2'};
Bool_ReExport = 0;

nPP = 81; % number of subjects

for s = 1:nPP
    ppPath = ['pp_' num2str(s)];
    Fpath = fullfile(datapath,ppPath,'Standing');
    mtbFiles = dir(fullfile(Fpath,'*.mtb'));
    nFiles = length(mtbFiles);
    ntrials = floor(nFiles./2);
    % Sort files base on name
    Names = {mtbFiles().name};
    [NamesSort, IndsSort] = sort(Names);
    for i = 1:ntrials
        % mtb files
        IndsSel = IndsSort(i*2-1:i*2);
        filename = {mtbFiles(IndsSel).name};
        % evaluate if the txt files are already exported
        f1 = filename{1}(1:end-4);
        f2 = filename{2}(1:end-4);
        f1New = fullfile(Fpath,[f1 '-000_00B42D0F.txt']);
        f1Old = fullfile(Fpath,[f1 '-000_00341911.txt']);
        f2New = fullfile(Fpath,[f2 '-000_00B42D0F.txt']);
        f2Old = fullfile(Fpath,[f2 '-000_00341911.txt']);
        BoolFile1 = exist(f1New,'file') | exist(f1Old,'file');
        BoolFile2 = exist(f2New,'file') | exist(f2Old,'file');
        if BoolFile1 && BoolFile2
            % outname of the .mat file
            OutName = [OrderMeas{i} '_data.mat'];
            OutPathMat = fullfile(OutPath,ppPath,'Standing');
            OutFile = fullfile(OutPathMat,OutName);
            if ~exist(OutFile,'file') || Bool_ReExport == 1
                % read the data
                [Data,header] = CombineData_StandingBalance(Fpath,{f1,f2},StringLocation);
                
%                 % plot figure with trunk acc for each subject
%                 if i ==1
%                     figure();
%                     subplot(1,2,1)
%                     plot(Data.Trunk.Acc); hold on;
%                     plot(Data.Trunk.AccRot,'--k');
%                     legend('x','y','z');
%                     subplot(1,2,2)
%                     plot(Data.Pelvis.Acc); hold on;
%                     plot(Data.Pelvis.AccRot,'--k');
%                     legend('x','y','z');
%                     set(gcf,'Position',[716   315   635   364]);
%                 end
                
                % save the datafiles
                if ~isfolder(OutPathMat); mkdir(OutPathMat); end
                save(OutFile,'Data','header');
                
            end
        end
    end
end


