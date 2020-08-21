%% Example script to load and plot data
%--------------------------------------
clear all;
% path to folder with txt files
ExportPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\Pilot_08_06\Export';

% filenames + sensors ID's
filename = 'Test3'; % filename
ExtSensors = {'_00B42D0F','_00B42D71','_00B42D95'}; % ID of sensors
StringLocation = {'Steer','Trunk','Frame'};

% importdata of the sensors
for i = 1:3
    Data.(StringLocation{i}) = importdata(fullfile(ExportPath,[filename ExtSensors{i} '.txt']));
end

% get the header (same for all files)
header = Data.Frame.textdata(end,:);

% display the header in command window
for i=1:length(header)
   disp([num2str(i) ' : ' header{i}]);
end

% add time vector
% sampling rate is 100hz here
for i = 1:3
    nfr = length(Data.(StringLocation{i}).data(:,1));
    Data.(StringLocation{i}).t = (1:nfr)./100;
end

%% Plot some figures

% plot orientation of three sensors
iRoll = find(strcmp(header,'Roll'));
figure('Name','euler angles');
for i=1:3
    subplot(1,3,i)
    plot(Data.(StringLocation{i}).t,Data.(StringLocation{i}).data(:,iRoll:iRoll+2));
    title(StringLocation{i})
    xlabel('time [s]');
    ylabel('orientation [deg]');
end
legend('x','y','z');

% plot angular velocity
iSel = find(strcmp(header,'Gyr_X')); % select index of gyroscope (angular velocity)
figure('Name','gyroscope');
for i=1:3
    subplot(1,3,i)
    plot(Data.(StringLocation{i}).t,Data.(StringLocation{i}).data(:,iSel:iSel+2));
    title(StringLocation{i})
    xlabel('time [s]');
    ylabel('angular velocity [deg/s]');
end
legend('x','y','z');

% plot linear acceleration
iSel = find(strcmp(header,'Acc_X')); % select index of gyroscope (angular velocity)
figure('Name','acceleration');
for i=1:3
    subplot(1,3,i)
    plot(Data.(StringLocation{i}).t,Data.(StringLocation{i}).data(:,iSel:iSel+2));
    title(StringLocation{i})
    xlabel('time [s]');
    ylabel('acceleration [m/s2]');
end
legend('x','y','z');


% plot linear acceleration without gravity
iSel = find(strcmp(header,'FreeAcc_E')); % select index of gyroscope (angular velocity)
figure('Name','Free acceleration');
for i=1:3
    subplot(1,3,i)
    plot(Data.(StringLocation{i}).t,Data.(StringLocation{i}).data(:,iSel:iSel+2));
    title(StringLocation{i})
    xlabel('time [s]');
    ylabel('acceleration [m/s2]');
end
legend('x','y','z');
