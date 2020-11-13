%% Clean example steer angle
%---------------------------
clear all; clc;
% data information
% load('normal_data_V3.mat');
% dt = [21 28];

% load('normal_data_V2.mat');
% dt = [17 21.5];
load('slow_data.mat');
dt = [tTrigger(2) tTrigger(3)];
dt = getCallibrationPhase(Data.Steer.t,dt,Data.Steer.QdWorld);

% interpolate rotation matrices if needed
if (length(Data.Frame.t) ~= length(Data.Steer.t)) || (any((Data.Frame.t-Data.Steer.t)~=0))
    [Data.Frame.Rint, Data.Steer.Rint, tint] = InterpolateRotMatrices(Data.Frame.R,Data.Steer.R,Data.Frame.t,Data.Steer.t);
    disp(['Interpolated rotation matrices for file: ' filename]);
else
    Data.Frame.Rint = Data.Frame.R;
    Data.Steer.Rint = Data.Steer.R;
    tint = Data.Frame.t;
end

BoolPlot = true;

% get hinge
[Rax,n_steer,n_frame] = GetHingeAxis(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,BoolPlot);
disp([n_steer n_frame]);
% 
% % get the hinge in full movement
% dt = [Data.Frame.t(1) Data.Frame.t(end)];
% [Rax2,n_steer2,n_frame2] = GetHingeAxis(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,BoolPlot);
% disp([n_steer2 n_frame2]);

% compute the angle of the steer
[qAxis] = GetAngleSteer(Data.Frame.R,Data.Steer.R,Rax);
% [qAxis2] = GetAngleSteer(Data.Frame.R,Data.Steer.R,Rax2);

% plot the steer angle
% figure();
plot(qAxis(:,1),'b'); hold on;
% plot(qAxis2(:,1),'--r');
