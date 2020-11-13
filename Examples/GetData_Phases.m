%% Compute all Phase information
%--------------------------------

%% Compute rotaton axis of the steer for each subject
clear all; close all; clc;
% Path information
DataPath  = 'E:\Data\Fietsproef\MatData';
FigPath = 'E:\Data\Fietsproef\Figures\HingeSteer';
nPP = 81;
Folders = {'Classic','EBike'};
OrderMeas = {'normal','slow','DualTask','extra','extra2','extra3'};
SensorLocation  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};

% Phases
TrialNames = {'Start','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2','add3','add4','add5','add6','add7'};
CallNames = {'CallPerson','CallBike','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2','add3','add4','add5','add6','add7'};

%% Get the axis of rotaton of the steer for each subject
ct = 1;
BoolPlot = true;
BoolSteerWarning = false;
% loop over all subjects
for s = 1:nPP
    ppPath = ['pp_' num2str(s)];
    for f = 1:length(Folders)
        for i =1:3
            % load the data
            OutName = [OrderMeas{i} '_data.mat'];
            OutPathMat = fullfile(DataPath,ppPath,Folders{f});
            filename = fullfile(OutPathMat,OutName);
            if exist(filename,'file')
                % load the file
                listOfVariables = who('-file', filename);
                load(filename,'tTrigger','Data','header');                
                if ismember('SteerAngle', listOfVariables) % returns true
                    load(filename,'SteerAngle');
                    BoolSteer = true;
                else
                    disp(['Steer angle not found in' filename]); 
                    BoolSteer = false;
                    BoolSteerWarning = true;
                end
                % detect if this is a callibration trial or not
                nEvents = length(tTrigger);   % number of events
                if nEvents == 12
                    PhaseNames = CallNames;
                elseif nEvents == 11
                    PhaseNames = TrialNames;
                else
                    PhaseNames = [];
                    disp([num2str(nEvents) ' detected in file ' filename '- . I expect 11 or 12 events and therefore skipped this file']);
                end
                
                if ~isempty(PhaseNames)                    
                    nsensor = 6;
                    for ev = 1:nEvents-1
                        for j = 1:nsensor
                            if ~isempty(Data.(SensorLocation{j}).data)
                                % get start and end of the time vector
                                t = Data.(SensorLocation{j}).t;
                                t0 = tTrigger(ev);
                                tend = tTrigger(ev+1);
                                % select the data in this time interval
                                iSel = t>=t0 & t<= tend;
                                % data structure
                                Phases.(SensorLocation{j}).(PhaseNames{ev}).data = ...
                                    Data.(SensorLocation{j}).data(iSel,:);
                                % time vector
                                Phases.(SensorLocation{j}).(PhaseNames{ev}).t = t(iSel);
                                % rotation matrix
                                Phases.(SensorLocation{j}).(PhaseNames{ev}).R = ...
                                    Data.(SensorLocation{j}).R(:,:,iSel);
                                % euler angles
                                Phases.(SensorLocation{j}).(PhaseNames{ev}).eul = ...
                                    Data.(SensorLocation{j}).eul(iSel,:);
                                % Raw data expressed in word frame
                                Phases.(SensorLocation{j}).(PhaseNames{ev}).AccWorld= ...
                                    Data.(SensorLocation{j}).AccWorld(iSel,:);
                                Phases.(SensorLocation{j}).(PhaseNames{ev}).QdWorld= ...
                                    Data.(SensorLocation{j}).QdWorld(iSel,:);
                            end
                        end
                        % Steer angle
                        if BoolSteer
                            iSel = SteerAngle.t>=t0 & SteerAngle.t<= tend;
                            Phases.SteerAngle.(PhaseNames{ev}).qSteer = SteerAngle.q(iSel,:);
                            Phases.SteerAngle.(PhaseNames{ev}).t = SteerAngle.t(iSel);
                        end
                    end
                    % save the structure Phases
                    save(filename,'Phases','-append');
                    clear Phases
                end                                
            end
        end
    end
    disp(['Subject ' num2str(s) ' / ' num2str(nPP)]);
end
if BoolSteerWarning 
   disp('Did not find the steer angle in all filse, make sure that you ran the script GetRotationAxisSteer_Subjects.m');
end




