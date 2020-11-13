function [R,n_steer,n_frame,qAxis] = GetHingeAxis_FrameInSteer(R_frame,R_steer,t,dt,varargin)
%GetHingeAxis Computes the rotation axis of a hinge joint
%   Input arguments:
%       (1) R_frame: rotation matrix of body 1 (frame) in world
%       (2) R_steer: rotation matri of body 2 (steer) in world
%       (3) t: time vector
%       (4) dt: time span of callibration movement
%       (5) optional inputs:
%           (a) BoolPlot figures (default is 0)
%   Output arguments:
%       (1) R: rotation matrix to compute rotation of frame w.r.t. steer
%       align the hinge (x euler angle)
%       (2) n_steer: vector with axis in the steer frame
%       (3) n_frame: vector with axis in the bike frame



BoolPlot = false;
if ~isempty(varargin)
    BoolPlot = varargin{1};
end

% select time 
iSel = t>=dt(1) & t<=dt(2);
tsel = t(iSel);
nfr = length(tsel);


% get the data in the time span
R_fr = R_frame(:,:,iSel);
R_st = R_steer(:,:,iSel);


% get rotation matrix with "the steer" expressed in "bike frame" coordinate
% system
Rfr_st = nan(3,3,nfr);
for i =1:nfr
    Rfr_st(:,:,i) = R_st(:,:,i)'*R_fr(:,:,i); %
end

% Create matrix A as in Zehr2007 (equation 2) with both the steer and the
% bike frame expressed in the world coordinate system
A = zeros(nfr*3,6);
for i = 1:nfr
    A((i-1)*3+1 : i*3 , 1:3) = R_fr(:,:,i); % rotation matrix steer
    A((i-1)*3+1 : i*3 , 4:6) = -R_st(:,:,i); % rotation matrix  frame
end

% singular value decomposition on matrix A
[~, ~, V]=svd(A,0); % singular value decomposition (A = U*S*V')

% get the orientation in steer and frame
n_frame = V(1:3,6)/norm(V(1:3,6)); %orientation in steer
n_steer = V(4:6,6)/norm(V(4:6,6)); %orientation in frame

%Compute the residuals
errorFrame = nan(nfr,3);
for i=1:nfr
    errorFrame(i,:)  = eye(3)*n_steer -  Rfr_st(:,:,i)*n_frame;
end
if BoolPlot
    figure();
    set(gcf,'Position',[341   410   929   387]);
    subplot(2,2,1)
    plot(tsel,errorFrame);
    ylabel('Errors [radians ?]');
    xlabel('Time [s]');
end

% adapt coordinate system bike frame such that x-axis aligns with the
% rotation axis

z = cross(n_steer,[0 1 0]);
y = cross(z,n_steer);
R =  [n_steer'; y; z];


% z = cross(n_frame,[0 1 0]);
% y = cross(z,n_frame);
% R =  [n_frame'; y; z];

% x = cross(n_steer, [0 1 0]);
% y = cross(x,n_steer);
% R = [x; y; n_steer'];

% x = cross(n_steer, [0 1 0]);
% z = cross(x,n_steer);
% R = [x; n_steer'; z];

%% compute steer angle when bool plot is true
if BoolPlot
        
    % compute steer angle
    R_Axis = nan(3,3,nfr);  
    R0 = (R*Rfr_st(:,:,1))';
    for i =1:nfr
        R_Axis(:,:,i) = (R*Rfr_st(:,:,i))*R0; % axis w.r.t. initial frame
    end
    qAxis = rotm2eul(R_Axis,'XYZ');
%     qAxis = rotm2eul(R_Axis,'ZYX');
%     qAxis = rotm2eul(R_Axis,'ZYX');

    subplot(2,2,2);
    plot(tsel,qAxis);
    legend('x','y-steer','z');
    xlabel('Time [s]');
end
if BoolPlot
    % get rotation matrix with "the steer" expressed in "bike frame" coordinate
    % system
    nfr = length(t);
    Rfr_st = nan(3,3,nfr);
    for i =1:nfr
        Rfr_st(:,:,i) = R_steer(:,:,i)'*R_frame(:,:,i); %
    end
    
    % get average orientation of steer w.r.t. frame
    qSteer = rotm2eul(Rfr_st);
    qMean = nanmean(qSteer);
    RMean =  eul2rotm(qMean);
    
    % in new coordinate system
    R_Axis = nan(3,3,nfr);
    R0 = (R*RMean)';
    for i =1:nfr
        R_Axis(:,:,i) = (R*Rfr_st(:,:,i))*R0;
    end
    
    % compute an plot euler angles
    qAxis = rotm2eul(R_Axis,'XYZ');
%     qAxis = rotm2eul(R_Axis,'ZYX');
%     qAxis = rotm2eul(R_Axis,'ZYZ');
    subplot(2,2,3:4);
    plot(t,qAxis);
    legend('x','y-steer','z');
    xlabel('time [s]');
    ylabel('Angle [rad]');
    title('full datafile');
    set(gca,'YLim',[-2 2]);
else
    qAxis = [];
end








end

