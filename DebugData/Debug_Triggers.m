%% Debug number of triggers
clear all; clc;
% path with the data
DataPath  = 'E:\Data\Fietsproef\MatData';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas       = {'normal','slow','DualTask','extra','extra2','extra3'};
OrderEvents     = {'Call1','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};


% create array with:
% - timing of triggers
% - file information
% - path to datafile
TriggerDat = nan(1000,20);
FileInfo = nan(1000,4);
PathInfo = cell(1000);
ct = 1;
for s =1:nPP
    ppPath = ['pp_' num2str(s)];
    for f = 1:length(Folders)
        for i=1:3
            OutName = [OrderMeas{i} '_data.mat'];
            OutPathMat = fullfile(DataPath,ppPath,Folders{f});
            filename = fullfile(OutPathMat,OutName);
            if exist(filename,'file')
                d = load(filename,'tTrigger');
                TriggerDat(ct,1:length(d.tTrigger)) = d.tTrigger;
                FileInfo(ct,:) = [s f i length(d.tTrigger)];
                PathInfo{ct} = fullfile(OutPathMat,OutName);
                ct= ct+1;
            end
        end
    end
end
TriggerDat(ct:end,:) = [];
FileInfo(ct:end,:) = [];
PathInfo(ct:end) = [];

% get the relative duration of each phase
Phases = diff(TriggerDat,[],2);
dtTrials = max(TriggerDat,[],2);
PhasesRel = Phases./repmat(dtTrials,1,19);


%% Figures with relative duraction events

nEvents = [10 11 12];
nTrials = length(FileInfo);
OrderEvents_call2     = {'Call1','Call2','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};
for j = nEvents
    iSel = FileInfo(:,4) == j;
    figure();
    for i =1:j-1
        subplot(3,4,i)
        plot(PhasesRel(iSel,i),'ok','MarkerFaceColor',[0 0 0]); hold on;
        if j == 10
            title(OrderEvents{i+1});
        elseif j==11
            title(OrderEvents{i});
        elseif j == 1
            title(OrderEvents_call2{i});
        end
        ylabel('Relative duraction');
        set(gca,'YLim',[0 0.3]);
    end
    PercFiles = sum(iSel)./nTrials;
    suptitle([' ntriggers : ' num2str(j) ' in ' num2str(round(PercFiles*100)) ' % of the files']);
    delete_box    
end

%% Print names of triggers with 12 inputs

iSel = FileInfo(:,4) == 12;
DispHeader(PathInfo(iSel));


%% 
OrderEvents     = {'Call-person','Call-bike','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};

% 0 (call-person) 1 (call bike 2 (small) 3 (slalom) 4  (obstacle) 5 (fullturn) 
% 6 (walk) 7 (shoulder) 8 (onehand) 9 (afterdrop) 10 (brake) 11
% nPlot = 30;
% iSel = find(FileInfo(:,4) == 12);
% for i =1:50 
%     datapath = PathInfo{iSel(i)};
%     load(datapath);
%     [ordEvents,BoolError] = DetectEvents_FullTurnBased(Data,tTrigger);
%     if BoolError
%         disp(num2str(i));
%         PlotDetailedFrame(Data,tTrigger,ordEvents);
%     end
%     set(gcf,'Position',[294         158        1211         724]);
% end
% 

%% Test if we can identify the trials automatically without the first callibration

iSel = find(FileInfo(:,4) == 12);
i = 36;
datapath = PathInfo{iSel(i)};
load(datapath);

% select data during full turn
iTurn = find(strcmp(OrderEvents,'FullTurn'));

% compute average angle of the frame in each phase
qdFrame = Data.Frame.QdWorld(:,3);
t = Data.Frame.t;
qdVect =nan(length(tTrigger)-1,1);
for i =1:length(tTrigger)-1
    iSel = t<=tTrigger(i+1) & t>=tTrigger(i);
    qdVect(i) = nanmean(qdFrame(iSel));
end
[qMax,iMax] = max(qdVect);
% PlotDetailedFrame(Data,tTrigger,ordEvents);
% if iMax ~= iTurn
%     if iMax + 1 == iTurn
%        % only one pulse for start, no callibration phase here
%        OrderEvents     = {'Start','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};
%        % there is a double click somwhere else
%        %    - mainly one click too much during walking
%        %    - or one click too much during single hand
%     end
%     



% 
% nPlot = 5;
% iSel = find(FileInfo(:,4) == 12);
% for i =1:nPlot    
%     datapath = PathInfo{iSel(i)};
%     load(datapath);
%     PlotDetailedSteer(Data,tTrigger,OrderEvents);
%     set(gcf,'Position',[143         594        1188         499]);
% end

% We will have to label this manually. having some problems with 

% nP = 30;
% iSel = find(FileInfo(:,4) == 11);
% datapath = PathInfo{iSel(nP)};
% load(datapath);
% % PlotDefaultFigures(D.Data,D.tTrigger);
% PlotDetailedFrame(Data,tTrigger,OrderEvents)



%% test Manual correction

Control_Triggers(Data,tTrigger)
