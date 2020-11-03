

%% Point to Main Folder

MainPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Software';
datapath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\EXPERIMENTEN';
OutPath  = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\MatData';
OutFigures = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\Figures';

% Bool close figures automatically
Bool_CloseFig = 1;

% add the functions to your matlab path
addpath(genpath(MainPath));

% location of sensors
StringLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
OrderEvents     = {'Call1','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','brake'};
OrderMeas       = {'normal','slow','DualTask'};

diary('LogBatchProcessing.txt');
nPP = 80;
Folders = {'Classic','EBike','Standing'};
for s = 1:nPP
    ppPath = ['pp_' num2str(s)];
    for f = 1:length(Folders)
        Fpath = fullfile(datapath,ppPath,Folders{f});
        mtbFiles = dir(fullfile(Fpath,'*.mtb'));
        nFiles = length(mtbFiles);
        ntrials = floor(nFiles./2);
        Dates = [mtbFiles().datenum];
        Dates = Dates-min(Dates);
        [DatesSort, IndsSort] = sort(Dates);
        for i=1:ntrials
            % mtb files
            IndsSel = IndsSort(i*2-1:i*2);
            filename = {mtbFiles(IndsSel).name};
            % evaluate if the txt files are already exported
            f1 = filename{1}(1:end-4);
            f2 = filename{2}(1:end-4);
            f1New = fullfile(Fpath,[f1 '_00B42D0F.txt']); 
            f1Old = fullfile(Fpath,[f1 '_00341911.txt']); 
            f2New = fullfile(Fpath,[f2 '_00B42D0F.txt']); 
            f2Old = fullfile(Fpath,[f2 '_00341911.txt']); 
            BoolFile1 = exist(f1New,'file') | exist(f1Old,'file');
            BoolFile2 = exist(f2New,'file') | exist(f2Old,'file');
            if BoolFile1 && BoolFile2
                
                % read the data
                [Data,tTrigger,header] = CombineRawData(Fpath,{f1,f2},StringLocation,OrderEvents);
                
                % plot the default figure with 
                h = PlotDefaultFigures(Data,tTrigger);
                
                % save the datafiles
                OutPathMat = fullfile(OutPath,ppPath,Folders{f});
                if ~isdir(OutPathMat); mkdir(OutPathMat); end
                OutName = [OrderMeas{i} '_data.mat'];
                save(fullfile(OutPathMat,OutName),'Data','tTrigger','header');
                
                % save the figure
                OutPathFig = fullfile(OutFigures,ppPath,Folders{f});
                if ~isdir(OutPathFig); mkdir(OutPathFig); end
                OutName = [OrderMeas{i} '_gyroWorld.fig'];
                saveas(h,fullfile(OutPathFig,OutName));
                if Bool_CloseFig
                    close(h);
                end
            end
        end
    end
end
diary off