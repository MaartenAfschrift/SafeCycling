%% Example script to load and plot data
%--------------------------------------
clear all; close all;
% path to folder with txt files
ExportPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\Pilot_08_21_s1';

% filenames + sensors ID's
filename = 'MT_Movement4'; % filename
ExtID = '_007';

% location of sensors
Loc  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
nsensor = length(Loc);

% sequential order of events
OrderEvents     = {'Call1','Call2','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','brake'};

% get the data
[Data,tTrigger,header] = CombineRawData(ExportPath,filename,Loc,OrderEvents,ExtID,1);

%% Working with rotation matrices



% convert rotation matrices to euler angles
for i = 1:nsensor
    Data.(Loc{i}).eul = rotm2eul(Data.(Loc{i}).R);    % default is roll-pitch-yaw ('ZYX')
end

% Callibration procedure

% test express accelerations in world frame
iSel = find(strcmp(header,'Acc_X')); % select index of gyroscope (angular velocity)
Acc = Data.Frame.data(:,iSel:iSel+2);
theta = Data.Frame.eul;
R = Data.Frame.R;
AccWorld = Rotate3Dvect(R,Acc);
ThetaWorld = Rotate3Dvect(R,theta);
figure();
subplot(1,2,1); plot(AccWorld);
subplot(1,2,2); plot(ThetaWorld); legend('x','y','z');


% First: rotate w.r.t. grativity
iSel = find(strcmp(header,'Acc_X')); % select index of gyroscope (angular velocity)
Acc = Data.Frame.data(1:20,iSel:iSel+2);
R = GetRotation_Gravity(Acc);
Racc = Acc*R;

% rotate such that x is pointing in forward direction
Rdir = roty_casadi(2.5);
Rsel = Data.Frame.Call1.R;
[Rout1] = Rotate3Dmat(Rsel,R);
[Rout] = Rotate3Dmat(Rout1,Rdir);
EulSel = rotm2eul(Rout,'ZYX');
figure(); plot(EulSel); legend('x','y','z');
% 
% 
% check if this rotation makes sense
Rsel = Data.Frame.small.R;
[Rout1] = Rotate3Dmat(Rsel,R);
[Rout] = Rotate3Dmat(Rout1,Rdir);
EulSel = rotm2eul(Rout);
figure(); 
subplot(1,2,1)
plot(EulSel);
hold on;
subplot(1,2,2)
plot(Data.Frame.small.eul);

%%
% callibration bicycle frame 
% iSel = find(strcmp(header,'Acc_X')); % select index of gyroscope (angular velocity)
% Acc = Data.Frame.Call2.data(:,iSel:iSel+2);
% theta = Data.Frame.Call2.eul; 
% R = 
% Accg = Acc*R;

% Rotate around x and z axis such that y-axis is vertical
% First rotation around x such that y component zeros








% rotate around z-axis such that first part of callibration is in forward -
% backward direction.

% callibrate other sensors w.r.t. frame



% Second: compute average rotation direction "This is not trivial !)

% idea: Get average direction motion using lowpass filter
R = Data.Frame.R;
t = Data.Frame.t;







% Richting hoeksnelheid: w/|w|

%% Plot some figures

% plot orientation of three sensors
iRoll = find(strcmp(header,'Roll'));
figure('Name','euler angles');
if ~isempty(iRoll)
    for i=1:nsensor
        subplot(2,3,i)
        plot(Data.(Loc{i}).t,Data.(Loc{i}).data(:,iRoll:iRoll+2));
        title(Loc{i})
        xlabel('time [s]');
        ylabel('orientation [deg]');
        vline(tTrigger,'--r');
    end
    legend('x','y','z');
end

% plot angular velocity
iSel = find(strcmp(header,'Gyr_X')); % select index of gyroscope (angular velocity)
figure('Name','gyroscope');
for i=1:nsensor
    subplot(2,3,i)
    plot(Data.(Loc{i}).t,Data.(Loc{i}).data(:,iSel:iSel+2));
    title(Loc{i})
    xlabel('time [s]');
    ylabel('angular velocity [deg/s]');
    vline(tTrigger,'--r');
    if i>3
        set(gca,'YLim',[-6 6]);
    end
end
legend('x','y','z');

% plot linear acceleration
iSel = find(strcmp(header,'Acc_X')); % select index of gyroscope (angular velocity)
figure('Name','acceleration');
for i=1:nsensor
    subplot(2,3,i)
    plot(Data.(Loc{i}).t,Data.(Loc{i}).data(:,iSel:iSel+2));
    title(Loc{i})
    xlabel('time [s]');
    ylabel('acceleration [m/s2]');
    vline(tTrigger,'--r');
    if i>3
        set(gca,'YLim',[-50 50]);
    end
end
legend('x','y','z');


% plot linear acceleration without gravity
iSel = find(strcmp(header,'FreeAcc_X')); % select index of gyroscope (angular velocity)
figure('Name','Free acceleration');
for i=1:nsensor
    subplot(2,3,i)
    plot(Data.(Loc{i}).t,Data.(Loc{i}).data(:,iSel:iSel+2));
    title(Loc{i})
    xlabel('time [s]');
    ylabel('acceleration [m/s2]');
    vline(tTrigger,'--r');
    if i>3
        set(gca,'YLim',[-50 50]);
    end
end
legend('x','y','z');

%% Example: Plot angular acceleration of the slalom only

% index of the slalom
iSlalom = find(strcmp(OrderEvents,'slalom'));

% plot angular velocity
iSel = find(strcmp(header,'Gyr_X')); % select index of gyroscope (angular velocity)
figure('Name','gyroscope');
for i=1:nsensor
    subplot(2,3,i)
    tSel = Data.(Loc{i}).(OrderEvents{iSlalom}).t;
    tSel = tSel-tSel(1);
    plot(tSel, Data.(Loc{i}).(OrderEvents{iSlalom}).data(:,iSel:iSel+2));
    title(Loc{i})
    xlabel('time [s]');
    ylabel('angular velocity [deg/s]');
    %     if i>3
    set(gca,'YLim',[-2.5 2.5]);
    %     end
end
legend('x','y','z');
suptitle('Angular velocity - slalom');