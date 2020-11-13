% Understand error in steer angle in Ebike
%--------------------------------------------

clear all; close all; clc;
FilesNOK = {
    'E:\Data\Fietsproef\MatData\pp_1\EBike\slow_data.mat';
    'E:\Data\Fietsproef\MatData\pp_2\EBike\normal_data.mat';
    'E:\Data\Fietsproef\MatData\pp_4\EBike\normal_data.mat';
    'E:\Data\Fietsproef\MatData\pp_6\EBike\normal_data.mat';
    'E:\Data\Fietsproef\MatData\pp_7\EBike\normal_data.mat';
    'E:\Data\Fietsproef\MatData\pp_8\EBike\normal_data.mat'};

FilesOK = {
    'E:\Data\Fietsproef\MatData\pp_1\Classic\slow_data.mat'
    'E:\Data\Fietsproef\MatData\pp_2\Classic\normal_data.mat'
    'E:\Data\Fietsproef\MatData\pp_4\Classic\normal_data.mat'
    'E:\Data\Fietsproef\MatData\pp_6\Classic\normal_data.mat'
    'E:\Data\Fietsproef\MatData\pp_7\Classic\normal_data.mat'
    'E:\Data\Fietsproef\MatData\pp_8\Classic\normal_data.mat'};
BoolPlot = true;
n_NOK = nan(length(FilesNOK),6);
for i =1:1
    load(FilesNOK{i});
    dt = [tTrigger(2) tTrigger(3)];
    dt = getCallibrationPhase(Data.Steer.t,dt,Data.Steer.QdWorld);
    [~,n_steer,n_frame,q1] = GetHingeAxis_FrameInSteer(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,BoolPlot);
    [~,n_steer,n_frame,q1b] = GetHingeAxis_V2(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,BoolPlot);
    
    n_NOK(i,:) = [n_steer' n_frame'];
end

BoolPlot = true;
n_OK = nan(length(FilesOK),6);
for i =1:1
    load(FilesOK{i});
    dt = [tTrigger(2) tTrigger(3)];
    dt = getCallibrationPhase(Data.Steer.t,dt,Data.Steer.QdWorld);
        [~,n_steer,n_frame,q2] = GetHingeAxis_V2(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,BoolPlot);
    [~,n_steer,n_frame,q2b] = GetHingeAxis_FrameInSteer(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,BoolPlot);
    n_OK(i,:) = [n_steer' n_frame'];
end
%%
disp('Files with errors');
disp(n_NOK);
disp('Files without errors');
disp(n_OK);

figure();
subplot(1,2,1)
plot(q1(:,1),'b'); hold on
plot(q1b(:,1),'--r');
subplot(1,2,2)
plot(q2(:,1),'b'); hold on
plot(q2b(:,1),'--r');



%% Test implementation

%
% load(FilesNOK{1});
% dt = [tTrigger(2) tTrigger(3)];
% dt = getCallibrationPhase(Data.Steer.t,dt,Data.Steer.QdWorld);
% [~,n_steer,n_frame] = GetHingeAxis(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,1);
% [~,n_steer1,n_frame1] = GetHingeAxis_FrameInSteer(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,1);

%% Test implementation with correct file

% load(FilesOK{1});
% dt = [tTrigger(2) tTrigger(3)];
% dt = getCallibrationPhase(Data.Steer.t,dt,Data.Steer.QdWorld);
% [~,n_steer,n_frame] = GetHingeAxis(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,1);
% [~,n_steer,n_frame2] = GetHingeAxis_FrameInSteer(Data.Frame.R,Data.Steer.R,Data.Frame.t,dt,1);


%% Compare input
% load(FilesOK{1});
%
%
% figure();
% load(FilesNOK{1});
% nfr = length(Data.Frame.t);
% Rst_fr = nan(3,3,nfr);
% for i =1:nfr
%     Rst_fr(:,:,i) = Data.Frame.R(:,:,i)'*Data.Steer.R(:,:,i); %
% end
% q = rotm2eul(Rst_fr,'XYZ');
% subplot(1,2,1);
% plot(q);
%
% load(FilesOK{1});
% nfr = length(Data.Frame.t);
% Rst_fr = nan(3,3,nfr);
% for i =1:nfr
%     Rst_fr(:,:,i) = Data.Frame.R(:,:,i)'*Data.Steer.R(:,:,i); %
% end
% q = rotm2eul(Rst_fr,'XYZ');
% subplot(1,2,2);
% plot(q);
