function [Data,tTrigger,header] = CombineRawData(datapath,filename,StringLocation,OrderEvents,varargin)
%CombineRawData Reads the exported txt files from mt manager and combines
%the raw data in a datastructure (Data)
%   datapath = string with path datafolder
%   filename= string with filename
%   StringLocation= cell array with names of locations on body
%   OrderEvents= cell array with sequential order of events in cycling
%   track
%   varargin:
%       (1) end of filename (typically file counter). Can be the same of
%       both stations (cell 1x1) or a separate one (cell 1x2). Note that
%       you should put the ID-counter of the new station first in case you
%       have separate ID-counters.
%       (2) Boolean if you exported the ID of the station in the output
%       filename. If this is the case you typically have one ID-counter for
%       both devices. If not, you have two counters (see varargin{1}).
%       (3)

% Index counter of files
% depending on how you export this, this is the same number for both devices or
% a separate one.
try
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
            dataNew(IndexRel,:) = data;                          % fill in measurement
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
    
    %% Trigger pulse for sync
    
    % Get timing of events
    for i = 1:nsensor
        if ~isempty(Data.(StringLocation{i}).data)
            iHeader = find(strcmp(header,'TrigIn1_Timestamp'));
            if length(Data.(StringLocation{i}).data(1,:)) >= iHeader    % only on the new sensors, so check if this exists
                triggerEvent = Data.(StringLocation{i}).data(:,iHeader);
                iTrigger = ~isnan(triggerEvent);
                Data.(StringLocation{i}).tTrigger_Raw = Data.(StringLocation{i}).t(iTrigger);
            else
                Data.(StringLocation{i}).tTrigger_Raw =[];
            end
        end
    end
    
    % combine trigger events, because there seem to be missing in some sensors
    tTrigger = nan(100,1); ct = 1; % pre allocate
    for i = 1:nsensor
        if ~isempty(Data.(StringLocation{i}).data)
            temp = Data.(StringLocation{i}).tTrigger_Raw;
            n = length(temp);
            tTrigger(ct:ct+n-1) = temp;
            ct = ct+n;
        end
    end
    tTrigger(ct:end) = []; % remove additional data
    tTrigger = unique(tTrigger);
    
    % Delete triggers that are caused by "double click" on the trigger button
    if ~isempty(tTrigger)
        dt = diff(tTrigger);
        tTreshold = 0.5; % minimum 100ms gap between triggers
        while min(dt)<tTreshold
            iError = dt < tTreshold;
            tTrigger(iError) = [];
            dt = diff(tTrigger);
        end
        
        % add start frame
        tTrigger = [0; tTrigger];
        
        % add tTrigger to datastructure
        for i = 1:nsensor
            if ~isempty(Data.(StringLocation{i}).data)
                Data.(StringLocation{i}).tTrigger = tTrigger;
            end
        end
    else
        disp(['       - No trigger pulse in trigger pulse in file: ' fullfile(datapath,filename{1})]);
        for i = 1:nsensor
            if ~isempty(Data.(StringLocation{i}).data)
                Data.(StringLocation{i}).tTrigger = [];
            end
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
    
    %% get the data for the different events
    
    % To Do: add some warnings when:
    %   - triggers are missing
    %   - too long ?
    %   - ...
    disp(['      - ' num2str(length(tTrigger)) ' triggers detected in file']);
    if length(tTrigger) == 10
        OrderEvents = OrderEvents(2:end);
        disp('      - no callibration selected');
    elseif length(tTrigger) == 12
        % we seem to have two bugs here:
        % (1) or there is a double trigger for the callibration (in the
        % middle).
        % (2) or there is a double trigger during the phase looking
        % backwards.
        OrderEvents = OrderEvents(2:end);
        disp('      - no callibration selected');
    end
    nEvents = length(tTrigger);   % number of events    
    if nEvents>=length(OrderEvents)
        for i = 1:length(OrderEvents)
            for j = 1:nsensor
                if ~isempty(Data.(StringLocation{j}).data)
                    % get start and end of the time vector
                    t = Data.(StringLocation{j}).t;
                    t0 = tTrigger(i);
                    if i < nEvents
                        tend = tTrigger(i+1);
                    else
                        tend = length(t);
                    end
                    % select the data in this time interval
                    iSel = t>=t0 & t<= tend;
                    % data structure
                    Data.(StringLocation{j}).(OrderEvents{i}).data = ...
                        Data.(StringLocation{j}).data(iSel,:);
                    % time vector
                    Data.(StringLocation{j}).(OrderEvents{i}).t = t(iSel);
                    % rotation matrix
                    Data.(StringLocation{j}).(OrderEvents{i}).R = ...
                        Data.(StringLocation{j}).R(:,:,iSel);
                    % euler angles
                    Data.(StringLocation{j}).(OrderEvents{i}).eul = ...
                        Data.(StringLocation{j}).eul(iSel,:);
                    % Raw data expressed in word frame
                    Data.(StringLocation{j}).(OrderEvents{i}).AccWorld= ...
                        Data.(StringLocation{j}).AccWorld(iSel,:);
                    Data.(StringLocation{j}).(OrderEvents{i}).QdWorld= ...
                        Data.(StringLocation{j}).QdWorld(iSel,:);
                end
            end
        end
    else
        disp(['      - Only : ' num2str(nEvents) ' events detected in file ' fullfile(datapath,filename{1})]);
    end
    
    % add path information to the datastructure:
    Data.Path.datapath = datapath;
    Data.Path.filename = filename;
    
    
catch
    disp('       - Unknown error in file');
    Data = [];
    tTrigger = [];
    header = [];
end

end

