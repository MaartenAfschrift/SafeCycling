

%% Point to Main Folder

MainPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Software';
datapath = 'E:\Data\Fietsproef\RawData';
OutPath  = 'E:\Data\Fietsproef\MatData';
OutFigures = 'E:\Data\Fietsproef\Figures';

% Bool close figures automatically
Bool_PlotFig = 0;
Bool_CloseFig = 1;
Bool_ReExport = 1;


% add the functions to your matlab path
addpath(genpath(MainPath));

% location of sensors
StringLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
OrderEvents     = {'Call1','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','temp','temp','temp'};
OrderMeas       = {'normal','slow','DualTask','extra','extra2','extra3'};

diary('LogBatchProcessing.txt');
disp('');
disp('Start batch processing');
disp(date);
nPP = 81;
Folders = {'Classic','EBike'};
for s = 1:nPP
    ppPath = ['pp_' num2str(s)];
    for f = 1:length(Folders)
        Fpath = fullfile(datapath,ppPath,Folders{f});
        mtbFiles = dir(fullfile(Fpath,'*.mtb'));
        nFiles = length(mtbFiles);
        ntrials = floor(nFiles./2);
        
        % coding based on time doesn't work when downloading data from
        % onedrive (i.e. date is based on time of download)
        %Dates = [mtbFiles().datenum];
        %Dates = Dates-min(Dates);
        %[DatesSort, IndsSort] = sort(Dates);
        
        % Sort files base on name
        Names = {mtbFiles().name};
        [NamesSort, IndsSort] = sort(Names);
        
        for i=1:ntrials
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
%             disp(filename)
            if BoolFile1 && BoolFile2
                
                % outname of the .mat file                
                OutName = [OrderMeas{i} '_data.mat'];
                OutPathMat = fullfile(OutPath,ppPath,Folders{f});
                OutFile = fullfile(OutPathMat,OutName);
                if ~exist(OutFile,'file') || Bool_ReExport == 1
                    
                    % read the data
                    [Data,tTrigger,header] = CombineRawData(Fpath,{f1,f2},StringLocation,OrderEvents);
                    
                    % plot and save the default figure with
                    if ~isempty(tTrigger) && ~isempty(Data) && Bool_PlotFig
                        h = PlotDefaultFigures(Data,tTrigger);
                        OutPathFig = fullfile(OutFigures,ppPath,Folders{f});
                        if ~isfolder(OutPathFig); mkdir(OutPathFig); end
                        OutName = [OrderMeas{i} '_gyroWorld.fig'];
                        saveas(h,fullfile(OutPathFig,OutName));
                        if Bool_CloseFig
                            close(h);
                        end
                    end
                    % save the datafiles                    
                    if ~isfolder(OutPathMat); mkdir(OutPathMat); end
                    save(OutFile,'Data','tTrigger','header');
                end
            end
        end
    end
end
diary off