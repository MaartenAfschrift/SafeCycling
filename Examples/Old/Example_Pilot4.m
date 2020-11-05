%% Example script to load and plot data
%--------------------------------------
clear all; close all;
% path to folder with txt files
ExportPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\Pilot_08_25_s1\normalbike';

% filenames + sensors ID's
filename = 'test_ebike_slow'; % filename
ExtID = {'001','000'};  % (1) output new station, (0) output old station.
BoolIDStation  = 0; % Boolean: 1 if ID name of the station is in the output name of the file (ID name is for example _00200387) 

% location of sensors
Loc  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
nsensor = length(Loc);

% sequential order of events
OrderEvents     = {'Call1','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','brake'};

% get and process the data
[Data,tTrigger,header] = CombineRawData(ExportPath,filename,Loc,OrderEvents,ExtID,0);


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
else
    for i=1:nsensor
        subplot(2,3,i)
        plot(Data.(Loc{i}).t,Data.(Loc{i}).eul);
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

% plot linear acceleration without gravity
figure('Name','acc world frame');
for i=1:nsensor
    subplot(2,3,i)
    plot(Data.(Loc{i}).t,Data.(Loc{i}).AccWorld);
    title(Loc{i})
    xlabel('time [s]');
    ylabel('acceleration [m/s2]');
    vline(tTrigger,'--r');
    if i>3
        set(gca,'YLim',[-50 50]);
    end
end
legend('x','y','z');

%% Plot some figures in specific parts of the parcours

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
    ylabel('angular velocity [rad/s]');
    %     if i>3
    set(gca,'YLim',[-2.5 2.5]);
    %     end
end
legend('x','y','z');
suptitle('Angular velocity - slalom');

% Plot angular velocity in world frame
figure('Name','gyroscope - world');
for i=1:nsensor
    subplot(2,3,i)
    tSel = Data.(Loc{i}).(OrderEvents{iSlalom}).t;
    tSel = tSel-tSel(1);
    plot(tSel, Data.(Loc{i}).(OrderEvents{iSlalom}).QdWorld);
    title(Loc{i})
    xlabel('time [s]');
    ylabel('angular velocity [rad/s]');
    set(gca,'YLim',[-2.5 2.5]);
end
legend('x','y','z');
suptitle('Angular velocity world frame - slalom');

% Plot acceleration in world frame
figure('Name','accelerometer - world');
for i=1:nsensor
    subplot(2,3,i)
    tSel = Data.(Loc{i}).(OrderEvents{iSlalom}).t;
    tSel = tSel-tSel(1);
    plot(tSel, Data.(Loc{i}).(OrderEvents{iSlalom}).AccWorld);
    title(Loc{i})
    xlabel('time [s]');
    ylabel('accelerometer - world[m/s2]');
%     if i>3
%         set(gca,'YLim',[-50 50]);
%     end
end
legend('x','y','z');
suptitle('Acceleration world frame - slalom');



%% Debugging: Work in progress....

% Align all sensors with world frame in callibration trial
% Based on one frame

% get rotation matrix in the first frame
t = Data.Steer.t;
R = Data.Steer.R;
R0 = squeeze(R(:,:,1));

[R] = Rotate3Dmat(R,R0'); % callibrate w.r.t.initial frame ?

% New idea: the goal here is to rotate around z-axis to minimize
% orientation around x-axis. (i.e. adapt coordinate system world so that
% x-axis aligns with x-axis of the sensor


% multiply rotation matrix with callibration frame
% [Rout] = Rotate3Dmat(R,R0');    % this is the rotation of the sensor w.r.t. the initial orientation in the world
% [Rout] = Rotate3Dmat(Rout,rotz(45));
% standard euler angles
xyz = rotm2eul(R);

% rotated aroudn z-axis euler angles
[Rout2] = Rotate3Dmat(R,rotz(-45)); % here rotation of 45 seems to align with North
xyz2 = rotm2eul(Rout2);

% rotated aroudn z-axis euler angles
[Rout2] = Rotate3Dmat(R,rotz(-45+180)); % movement in opposite direction
xyz3 = rotm2eul(Rout2);

figure(); 
subplot(1,3,1);
plot(t,xyz);
subplot(1,3,2);
plot(t,xyz2);
subplot(1,3,3);
plot(t,xyz3);
legend('x','y','z');

% 
% % correct for average movement direction in trials
% nEvents = length(OrderEvents);
% for i=1:nsensor
%     for j = nEvents
%         % get the rotation matrix
%         R = Data.(Loc{i}).(OrderEvents{j}).R; % R is the rotation from sensor frame to world frame (or the opposite ?)
%         
%         % we want to rotate around 
% %         theta = Data.(Loc{i}).(OrderEvents{j}).eul;
% %         thetaMean = nanmean(theta);
%     end
% end
% 





