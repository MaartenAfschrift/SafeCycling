%% Example on how to analyse data
%--------------------------------

clear all; close all; clc;

DataPath  = 'E:\Data\Fietsproef';
FigPath = 'E:\Data\Fietsproef\Figures\HingeSteer';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas = {'normal','slow','DualTask','extra','extra2','extra3'};
SensorLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};

% here we want to compute the variation in steer angle during the "narrow
% lane" task (i.e. first task cycling parcours
ParcousSelected = 'slalom';

% load the info of the folders
load(fullfile(DataPath,'RawData','ppInfo.mat'),'ppYoung','ppEld');


% flow control
ComputeDataMatrix = true; % Run part to compute datamatrix (or load saved .mat file)
BoolPlot2 = false; % individual plot for each subject with the input data to copumpute variance

% tresholds
qd_threshold = 99; % 0.3 % radians/s for steady state biking after slalom (i.e. before start turn towards obstacle part)
threshold_drift = 0.3; % 0.3 radians in this task

%% Get the Datamatrix
if ComputeDataMatrix
    DataMatrix = nan(100*3*2,6); % pre allocat matrix with all the data
    header_DataMatrix =  {'s-ID','bike-ID','Speed-ID','VarSteerAngle','BoolElderly','Error'}; % header for the datamatrix
    diary('LogExample_NarrowLane.txt');
    
    ct = 1;
    for s = 1:nPP
        ppPath = ['pp_' num2str(s)];
        %   h1 = figure();
        
        if BoolPlot2
            h2 = figure();
        end
        
        % detect if this is a young or an older subject
        BoolEld = any(ppEld ==s);
        BoolYoung = any(ppYoung ==s);
        if BoolEld && BoolYoung
            disp(['Subject ' num2str(s) ' is both young and old. adapt this in the excel file']);
        end
        
        
        for f = 1:length(Folders)
            for i =1:3
                % load the data
                OutName = [OrderMeas{i} '_data.mat'];
                OutPathMat = fullfile(DataPath,'MatData',ppPath,Folders{f});
                filename = fullfile(OutPathMat,OutName);
                if exist(filename,'file')
                    % check if the variable Phases exist in the datafile
                    %                 listOfVariables = who('-file', filename);
                    %                 if ismember('Phases', listOfVariables) % returns true
                    %                     BoolPhases = true;
                    %                 else
                    %                     BoolPhases = false;
                    %                 end
                    load(filename,'Phases','header');
                    
                    if exist('Phases','var')
                        BoolErrorFlag = 0;
                        % get the variance in steer angle
                        if isfield(Phases,'SteerAngle') && ~isempty(Phases.SteerAngle.slalom.t)
                            q = Phases.SteerAngle.slalom.qSteer(:,1); % steer angle aroud x-axis
                            t = Phases.SteerAngle.slalom.t;
                            
                            % we want all the data before the subject turn towards the
                            % slalom track. We can easility identify this based on the
                            % movement direction. You can find the orientation of the
                            % frame in the world (in euler angles) in the field eul.
                            % the orientation around the x-axis shows if the frame is
                            % facing in the "forward" or "backward" direction.
                            eul = Phases.Frame.slalom.eul;
                            teul = Phases.Frame.slalom.t;
                            
                            % also interpret this based on the angular
                            % velocity of the frame in the world
                            tqd = Phases.Frame.slalom.t;
                            qd = Phases.Frame.slalom.QdWorld;
                            
                            %                             % we will have to adapt the euler angles to
                            %                             % have a proper interpretation
                            %                             %%
                            %                             R0 = Phases.Trunk.CallPerson.R(:,:,end);
                            %                             nfr = length(tqd);
                            %                             R = Phases.Frame.slalom.R;
                            %                             Rrel = nan(3,3,nfr);
                            %                             for ifr = 1:nfr
                            %                                 Rrel(:,:,ifr) =  R(:,:,ifr)*R0';
                            %                             end
                            %                             eulRel = rotm2eul(Rrel);
                            %                             figure(); plot(eulRel); legend('x','y','z')
                            %                             %%
                            %
                            % get index turned
                            eulAbs = abs(eul);
                            iTurned = find(eul(:,1) < 0,1,'last');
                            %                             figure(); plot(teul,abs(eul)); vline(teul(iTurned));
                            t0 = teul(1);
                            if isempty(iTurned)
                                tend = teul(end); % just select end of file (indicates that trigger pulse was too early
                                disp(['possible error in file: ' filename ]);
                                BoolErrorFlag = 1;
                            else
                                % find last time the time derivative of the orientation is
                                % is positive before iTurned                                
                                iBeforeTurn = 1:iTurned;
                                iLastNoTurn = find(abs(qd(iBeforeTurn,3))<qd_threshold,1,'last');
                                tend = teul(iLastNoTurn);
                            end
                            % just select end of file (indicates that trigger pulse was too early
                            if isempty(tend)
                                tend = teul(end);
                                BoolErrorFlag = 1;
                                disp(['possible error in file: ' filename ])
                            end
                            
                            % evaluate if there is drift in the sensor
                            % test if there is drift on the sensors
                            [tnarrow,qnarrow] = GetSteerAngleNarrowLane(Phases);
                            qav_3s_t0 = nanmean(qnarrow(tnarrow<tnarrow(1)+3));
                            qav_3s_end = nanmean(qnarrow(tnarrow>tnarrow(end)-3));
                            drift = abs(qav_3s_end-qav_3s_t0);
                            if drift > threshold_drift
                                BoolErrorFlag = 1;
                                disp(['most likely drift in : ' filename ' reported as an error' ])
                            end
                            
                            % selecte indices
                            iSel = t>=t0 & t<=tend; % indices between start and end
                            qsel = q(iSel); % angle selected in time frame
                            tsel = t(iSel); % time vector selected
                            
                            % compute the variance in steering angle
                            qVar = var(qsel);
                            qVarDeg = qVar*180/pi;
                            
                            % store the variance in an array
                            DataMatrix(ct,1) = s;
                            DataMatrix(ct,2) = f;
                            DataMatrix(ct,3) = i;
                            DataMatrix(ct,4) = qVarDeg;
                            DataMatrix(ct,5) = BoolEld;
                            DataMatrix(ct,6) = BoolErrorFlag;
                            
                            ct = ct+1; % counter to fill row of DataMatrix
                            % you can the selected steering angle by uncommenting this
                            % code (also uncomment h2 = figure() before start for loop over f
                            if BoolPlot2
                                figure(h2);
                                subplot(2,3,(f-1)*3 + i);
                                plot(t,q); hold on;
                                plot(tsel,qsel,'--r');
                                xlabel('Time [s]');
                                ylabel('Steer angle [rad]');
                                title([Folders{f} ' ' ppPath]);
                            end
                            
                            % you can visualise the detection of the "small" part using
                            % this code (also uncomment h1 = figure() before start for loop over f
                            %                 figure(h1);
                            %                 subplot(2,3,(f-1)*3 + i);
                            %                 plot(teul,eul);
                            %                 vline(tsel(end));
                            %                 legend('x','y','z');
                            %                 title(Folders{f});
                            %                 xlabel('Time [s]');
                            %                 xlabel('orientation in world [rad]');
                        end
                    end
                end
            end
        end
        disp(['Subject ' num2str(s) ' / ' num2str(nPP)]);
    end
    % save the datamatrix
    if ~isfolder(fullfile(DataPath,'Outcomes'))
        mkdir(fullfile(DataPath,'Outcomes'));
    end
    save(fullfile(DataPath,'Outcomes','SlalomSteerAngle.mat'),'DataMatrix','header_DataMatrix');
    diary off
else
    load(fullfile(DataPath,'Outcomes','SlalomSteerAngle.mat'),'DataMatrix','header_DataMatrix');
end

%% Detect some outliers
% TO DO:check in code what is causing this one outlier


iError = DataMatrix(:,4)>20;
ErrorRows = DataMatrix(iError,:);

for i=1:length(ErrorRows(:,1))
    ErrSel = ErrorRows(i,:);
    OutName = [OrderMeas{ErrSel(3)} '_data.mat'];
    OutPathMat = fullfile(DataPath,'MatData',['pp_' num2str(ErrSel(3))],Folders{ErrSel(2)});
    filename = fullfile(OutPathMat,OutName);
    disp(['Outlier in ' filename ' variance in steering angle is ' num2str(ErrSel(4)) '. Evaluate what is causing this outlier']);
end


% remove outlier
DataMatrix(iError,:) = [];





%% Visual comparison of variance in steer angle

% Tip: I would always use the same colors for all graphs in your thesis. So
% pick them carefully :).
CYoung = [91 91 213]./255;%  color for young (see https://www.rapidtables.com/web/color/RGB_Color.html)
CEld = [179 77 40]./255; % color for elderly (see https://www.rapidtables.com/web/color/RGB_Color.html)
mk  = 3;

figure();
subplot(1,2,1)
% note fore now without errors possible DataMatrix(:,6) == 0
% normal bike - normal speed  [young Old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1& DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSel,4),CEld,mk); hold on;

% normal bike - slow speed - [young old
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 1& DataMatrix(:,6) == 0;
PlotBar(4,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 1& DataMatrix(:,6) == 0;
PlotBar(5,DataMatrix(iSel,4),CEld,mk); hold on;

% normal bike - dual task - [young old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 1& DataMatrix(:,6) == 0;
PlotBar(7,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 1& DataMatrix(:,6) == 0;
PlotBar(8,DataMatrix(iSel,4),CEld,mk); hold on;

ylabel('Variance steering angle [deg]');
set(gca,'XTick',[1.5 4.5 7.5]);
set(gca,'XTickLabel',{'Normal','Slow','DualTask'});
title('Normal Bike');
set(gca,'YLim',[0 20]); % adapt this based on maxiaml values (make sure you don't exclude datapoints)
set(gca,'Box','off')
set(gca,'FontSize',10);
set(gca,'LineWidth',1);

subplot(1,2,2)
% note fore now without errors possible DataMatrix(:,6) == 0
% normal bike - normal speed  [young Old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(1,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 1 & DataMatrix(:,2) == 1 & DataMatrix(:,6) == 0;
PlotBar(2,DataMatrix(iSel,4),CEld,mk); hold on;

% normal bike - slow speed - [young old
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(4,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 2 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(5,DataMatrix(iSel,4),CEld,mk); hold on;

% normal bike - dual task - [young old]
iSel = DataMatrix(:,5) == 0 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(7,DataMatrix(iSel,4),CYoung,mk); hold on;
iSel = DataMatrix(:,5) == 1 &  DataMatrix(:,3) == 3 & DataMatrix(:,2) == 2 & DataMatrix(:,6) == 0;
PlotBar(8,DataMatrix(iSel,4),CEld,mk); hold on;

set(gca,'XTick',[1.5 4.5 7.5]);
set(gca,'XTickLabel',{'Normal','Slow','DualTask'});
title('E-Bike');
set(gca,'YLim',[0 20]);% adapt this based on maxiaml values (make sure you don't exclude datapoints)
set(gca,'Box','off');
legend('Young','Old');
ax = gca;
l1 = ax.Children(4);
l2 = ax.Children(2);
legend([l1 l2],{'Young','Old'});
set(gca,'FontSize',10);
set(gca,'LineWidth',1);






