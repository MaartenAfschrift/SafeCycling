%% Example script to load and plot data
%--------------------------------------
clear all; close all;
% path to folder with txt files
ExportPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\Pilot_08_18';

% filenames + sensors ID's
filename = 'Trial3'; % filename

% location of sensors
Loc  = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
nsensor = length(Loc);

% sequential order of events
OrderEvents     = {'small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','brake'};

% get the data
[Data,tTrigger,header] = CombineRawData(ExportPath,filename);

% Richting hoeksnelheid: w/|w|

%% Plot some figures

% plot orientation of three sensors
iRoll = find(strcmp(header,'Roll'));
figure('Name','euler angles');
for i=1:nsensor
    subplot(2,3,i)
    plot(Data.(Loc{i}).t,Data.(Loc{i}).data(:,iRoll:iRoll+2));
    title(Loc{i})
    xlabel('time [s]');
    ylabel('orientation [deg]');
    vline(tTrigger,'--r');
end
legend('x','y','z');

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