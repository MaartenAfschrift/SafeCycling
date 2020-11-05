function [Data,header] = CombineData_StandingBalance(datapath,filename,StringLocation,varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


if ~isempty(varargin)
    ExtIDCell = varargin{1};
    if length(ExtIDCell) ==2
        % separate ID's for both stations
        ExtID1 = ExtIDCell{1};
        ExtID2 = ExtIDCell{2};
    else
        % same ID for both stations
        ExtID1 = ExtIDCell{1};
        ExtID2 = ExtIDCell{1};
    end
else
    ExtID1 = [];
    ExtID2 = [];
end

% if the ID of the station is exported or not
ID_bool = 0;
IDname1 =[];
IDname2 =[];
if length(varargin)>1 && varargin{2}==1
    % ID selection
    ID_bool = 2;
    IDname2 ='_00200387';
    IDname1 ='_01200677';
end

% general information
%   ID of the sensors
ExtSensors      = {'_00B42D0F','_00B42D71','_00B42D95','_00341911','_00341912','_00342392'};

% check if filename is a string of a cell array
if iscell(filename)
    % check if filename1 correspons with new sensors
    filename1 = filename{1};
    filename2 = filename{2};
else
    filename1 = filename;
    filename2 = filename;
end
%% Import the data
disp(['Start processing file: ' fullfile(datapath,filename{1})]);

nsensor         = length(ExtSensors);
% importdata of the sensors
for i = 1:nsensor
    if i<4
        IDsel = IDname1;
        ExtSel = ExtID1;
    else
        IDsel = IDname2;
        ExtSel = ExtID2;
    end
    % evaluate if the filename exists
    pathfile1 = fullfile(datapath,[filename1 IDsel ExtSel '-000' ExtSensors{i}  '.txt']);
    pathfile2 = fullfile(datapath,[filename2 IDsel ExtSel '-000' ExtSensors{i}  '.txt']);
    if exist(pathfile1,'file')
        Data.(StringLocation{i}) = importdata(pathfile1);
        pathfileSel{i} = pathfile1;
    elseif exist(pathfile2,'file')
        Data.(StringLocation{i}) = importdata(pathfile2);
        pathfileSel{i} = pathfile2;
    else
        error(['could not find file: ' filename]);
    end
    % load the data
    if isfield(Data.(StringLocation{i}),'textdata')
        Data.(StringLocation{i}).header = Data.(StringLocation{i}).textdata(end,:);
    else
        % this is the typical 1kb file
        Data.(StringLocation{i}) = [];
        Data.(StringLocation{i}).data = [];
        disp(['       - Warning: not all data included in file ' fullfile(datapath,pathfileSel{i})]);
    end
end

% adapt datastructure to fill in NaNs when data was not received by
% wireless system.
% note: sometimes problems with this counter for the index. There is a
% treshold at a specific value when the index resets to 0. For the older
% system this seems to be 65535 (checked this in the manual.pdf). Adapt this !
MaxCt = 65535;
for i = 1:nsensor
    if ~isempty(Data.(StringLocation{i}).data)
        data = Data.(StringLocation{i}).data;   % data the data matrix
        IndexCounter = data(:,1);               % indexes with measurement
        % verify if the package counter is going to reset
        if any(IndexCounter>(MaxCt-200))
            [MaxCounter,iMax] = max(IndexCounter);
            Inds = 1:length(IndexCounter);
            IndAbove = IndexCounter<MaxCounter & Inds'>iMax; % all indexes after max that are smaller than the max value
            IndexCounter(IndAbove) = IndexCounter(IndAbove)+MaxCt;
        end
        % update the data vector with missing frames
        nIndex = IndexCounter(end)-IndexCounter(1) + 1; % total number of time frames
        IndexRel = IndexCounter - IndexCounter(1)+1;    % first index number is 1
        dataNew = nan(nIndex,size(data,2));             % pre allocate matrix
        dataNew(IndexRel,:) = data;                      % fill in measurement
        Data.(StringLocation{i}).data = dataNew;        % adapt data matrix
        
        % display warning message when more than 5% of the file is missing
        if length(IndexRel)<nIndex*0.95
            PercCaptured = length(IndexRel)./ nIndex;
            disp(['      - Warning: only ' num2str(PercCaptured) ' % of the data captured in sensor on ' StringLocation{i} ' in file ' pathfileSel{i}]);
        end
    end
end

% get the header (same for all files)
header = Data.Frame.textdata(end,:);

% add time vector
% sampling rate is 100hz herz in new sensors and 75 herz in old sensors
for i = 1:nsensor
    if ~isempty(Data.(StringLocation{i}).data)
        nfr = length(Data.(StringLocation{i}).data(:,1));
        if i<4
            Data.(StringLocation{i}).t = (1:nfr)./100;
        else
            Data.(StringLocation{i}).t = (1:nfr)./75;
        end
    end
end

% get the final time in the 6 sensors and add NaN if needed
tsensors = nan(1,6);
for i =1:nsensor
    tsensors(i) = Data.(StringLocation{i}).t(end);
end
tEnd = max(tsensors);
for i =1:nsensor
    if Data.(StringLocation{i}).t(end)<tEnd
        Data.(StringLocation{i}).t = [Data.(StringLocation{i}).t tEnd];
        Data.(StringLocation{i}).data = [Data.(StringLocation{i}).data; nan(size(Data.(StringLocation{i}).data(1,:)))];
    end
end


%% Convert rotation matrices to Euler angles

% convert Nx9 array to 3x3xN array
iRot = find(strcmp(header,'Mat[1][1]'));
if ~isempty(iRot)
    
    % read rotation matrices
    for i = 1:nsensor
        if ~isempty(Data.(StringLocation{i}).data)
            nfr = length(Data.(StringLocation{i}).t);
            Data.(StringLocation{i}).R = nan(3,3,nfr);
            for j = 1:nfr
                for k = 1:3
                    iSel = (k-1)*3 : (k-1)*3+2;
                    Data.(StringLocation{i}).R(:,k,j) = Data.(StringLocation{i}).data(j,iRot+iSel);
                end
            end
        end
    end
    
    % convert rotation matrices to euler angles
    for i = 1:nsensor
        if ~isempty(Data.(StringLocation{i}).data)
            Data.(StringLocation{i}).eul = rotm2eul(Data.(StringLocation{i}).R);    % default is roll-pitch-yaw ('ZYX')
        end
    end
    
else
    disp('      - Rotation matrices were not exported. Please adjust export settings');
end



%% Express data in world coordinate system for each sensor

iAcc = find(strcmp(header,'Acc_X')); % select index of gyroscope (angular velocity)
iGyro = find(strcmp(header,'Gyr_X')); % select index of gyroscope (angular velocity)

for i = 1:nsensor
    if ~isempty(Data.(StringLocation{i}).data)
        Acc = Data.(StringLocation{i}).data(:,iAcc:iAcc +2);
        Qd = Data.(StringLocation{i}).data(:,iGyro:iGyro+2);
        R = Data.(StringLocation{i}).R;
        Data.(StringLocation{i}).AccWorld = Rotate3Dvect(R,Acc);
        Data.(StringLocation{i}).QdWorld = Rotate3Dvect(R,Qd);
    end
end

%% Compute the outcomes as described in De Groote 2020
% https://www.biorxiv.org/content/10.1101/2020.05.29.123620v1.full.pdf+html

% Hard to identify medio-lateral and anterior posterior here. We could
% keep everything in the local coordinate system and assume (as in the
% paper) that the sensors are aligned.

SensorsSel = {'Pelvis','Trunk'};
for i = 1:length(SensorsSel)
    if ~isempty(Data.(SensorsSel{i}).data)
        
        % get the acceleration
        Acc = Data.(SensorsSel{i}).data(:,iAcc:iAcc +2);
        Data.(SensorsSel{i}).Acc = Acc;
        
        % get the rotated acceleration (acc works around x-axis)
        Acc_NoNan = Data.(SensorsSel{i}).Acc;
        iNan = isnan(Data.(SensorsSel{i}).Acc(:,1));
        Acc_NoNan(iNan,:) = [];
        [R] = GetRotation_StandingBalance(Acc_NoNan); % rotate slightly around y and then around z axis so that x axis aligns with gravity
        AccRot = Data.(SensorsSel{i}).Acc*R;
        
        % remove the mean
        MeanAcc = nanmean(AccRot);
        AccRel = AccRot-MeanAcc;
        
        % get the RMS value
        AccRMS = rms(AccRel,'omitnan');
        
        % get the mean absolute value
        AccMean = nanmean(abs(AccRel));
        
        % store the outcomes in the datastructure
        Data.(SensorsSel{i}).AccRMS = AccRMS;
        Data.(SensorsSel{i}).AccMean = AccMean;
        Data.(SensorsSel{i}).AccRot = AccRot;
        
    end
end





end

