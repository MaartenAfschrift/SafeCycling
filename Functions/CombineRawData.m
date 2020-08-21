function [Data,tTrigger,header] = CombineRawData(datapath,filename)
%CombineRawData Reads the exported txt files from mt manager and combines
%the raw data in a datastructure (Data)
%   Detailed explanation goes here


% general information
%   ID of the sensors
ExtSensors      = {'_00B42D0F','_00B42D71','_00B42D95','_00341911','_00341912','_00342392'};
%   Location of the sensors
StringLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
%   Order of events
OrderEvents     = {'small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','brake'};

%% Import the data

nsensor         = length(ExtSensors);
% importdata of the sensors
for i = 1:nsensor
    Data.(StringLocation{i}) = importdata(fullfile(datapath,[filename ExtSensors{i} '.txt']));
    Data.(StringLocation{i}).header = Data.(StringLocation{i}).textdata(end,:);
end

% adapt datastructure to fill in NaNs when data was not received by
% wireless system.
for i = 1:nsensor
    data = Data.(StringLocation{i}).data;   % data the data matrix
    IndexCounter = data(:,1);               % indexes with measurement
    nIndex = IndexCounter(end)-IndexCounter(1) + 1; % total number of time frames
    IndexRel = IndexCounter - IndexCounter(1)+1;    % first index number is 1
    dataNew = nan(nIndex,size(data,2));             % pre allocate matrix
    dataNew(IndexRel,:) = data;                          % fill in measurement
    Data.(StringLocation{i}).data = dataNew;        % adapt data matrix
end

% get the header (same for all files)
header = Data.Frame.textdata(end,:);

% add time vector
% sampling rate is 100hz herz in new sensors and 75 herz in old sensors
for i = 1:nsensor
    nfr = length(Data.(StringLocation{i}).data(:,1));
    if i<4        
        Data.(StringLocation{i}).t = (1:nfr)./100;
    else
        Data.(StringLocation{i}).t = (1:nfr)./75;
    end
end

%% Trigger pulse for sync

% Get timing of events
for i = 1:nsensor
    iHeader = find(strcmp(header,'TrigIn1_Timestamp'));
    if length(Data.(StringLocation{i}).data(1,:)) >= iHeader    % only on the new sensors, so check if this exists
        triggerEvent = Data.(StringLocation{i}).data(:,iHeader);
        iTrigger = ~isnan(triggerEvent);
        Data.(StringLocation{i}).tTrigger_Raw = Data.(StringLocation{i}).t(iTrigger);
    else
        Data.(StringLocation{i}).tTrigger_Raw =[];
    end
end

% combine trigger events, because there seem to be missing in some sensors
tTrigger = nan(100,1); ct = 1; % pre allocate
for i = 1:nsensor
    temp = Data.(StringLocation{i}).tTrigger_Raw;
    n = length(temp);
    tTrigger(ct:ct+n-1) = temp;
    ct = ct+n;
end
tTrigger(ct:end) = []; % remove additional data
tTrigger = unique(tTrigger);

% Delete triggers that are caused by "double click" on the trigger buttong
dt = diff(tTrigger);
tTreshold = 0.5; % minimum 0.5s gap between triggers
while min(dt)<tTreshold
   iError = dt < tTreshold;
   tTrigger(iError) = [];
   dt = diff(tTrigger);
end

% add start frame
tTrigger = [0; tTrigger];

% add tTrigger to datastructure
for i = 1:nsensor
    Data.(StringLocation{i}).tTrigger = tTrigger;
end

%% get the data for the different events

% To Do: add some warnings when:
%   - triggers are missing
%   - too long ?
%   - ...

nEvents = length(tTrigger);   % number of events
for i = 1:nEvents
    for j = 1:nsensor
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
        Data.(StringLocation{j}).(OrderEvents{i}).data = ...
            Data.(StringLocation{j}).data(iSel,:);
        Data.(StringLocation{j}).(OrderEvents{i}).t = t(iSel);
    end
end



end

