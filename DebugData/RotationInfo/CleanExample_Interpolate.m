%% Clean example steer angle
%---------------------------
clear all; clc;
% data information
% load('normal_data_V3.mat');
% dt = [21 28];

% load('normal_data_V2.mat');
% dt = [17 21.5];

% load('normal_data.mat');


%% Trial with error
load('slow_data.mat');
dt = [tTrigger(2) tTrigger(3)];
dt(1) = dt(1) -3;
dt = getCallibrationPhase(Data.Steer.t,dt,Data.Steer.QdWorld);
BoolPlot = true;

% get hinge
[Rax,n_steer,n_frame] = GetHingeAxis_Temp(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,BoolPlot);
disp([n_steer n_frame]);

%% trial without problems
load('normal_data_V2.mat');
dt = [tTrigger(2) tTrigger(3)];
dt(1) = dt(1) -3;
dt = getCallibrationPhase(Data.Steer.t,dt,Data.Steer.QdWorld);
BoolPlot = true;

% get hinge
[Rax2,n_steer2,n_frame2] = GetHingeAxis_Temp(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,BoolPlot);
disp([n_steer2 n_frame2]);



%%
% plot orientations

figure();

load('slow_data.mat');
subplot(2,2,1);
plot(Data.Steer.t,Data.Steer.eul);
subplot(2,2,2);
plot(Data.Frame.t,Data.Frame.eul);

load('normal_data_V2.mat');
subplot(2,2,3)
plot(Data.Steer.t,Data.Steer.eul);
subplot(2,2,4);
plot(Data.Frame.t,Data.Frame.eul);

for i =1:4
    subplot(2,2,i)
    set(gca,'XLim',[0 40]);
end


% plot orientations

figure();

load('slow_data.mat');
subplot(2,2,1);
plot(Data.Steer.t,Data.Steer.QdWorld);
subplot(2,2,2);
plot(Data.Frame.t,Data.Frame.QdWorld);

load('normal_data_V2.mat');
subplot(2,2,3)
plot(Data.Steer.t,Data.Steer.QdWorld);
subplot(2,2,4);
plot(Data.Frame.t,Data.Frame.QdWorld);

for i =1:4
    subplot(2,2,i)
    set(gca,'XLim',[0 40]);
end
