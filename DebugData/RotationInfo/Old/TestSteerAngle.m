%% Test callibration
clear all; close all; clc;


% load('normal_data.mat');
% 
% % select indices of callibration
% dt = [17 44];
% iFrame = Data.Frame.t>=dt(1) & Data.Frame.t<=dt(2);
% iSteer = Data.Steer.t>=dt(1) & Data.Steer.t<=dt(2);
% 
% % get the rotation matrices
% R_fr = Data.Frame.R(:,:,iFrame);
% R_st = Data.Steer.R(:,:,iSteer);
% t_fr = Data.Frame.t(iFrame);
% t_st = Data.Steer.t(iSteer);
% 
% t = t_fr;
% save('ExampleData.mat','R_fr','R_st','t');
load('ExampleData.mat');



%% callibration procedure

nfr = length(t);
% create opti problem
import casadi.*
opti = casadi.Opti();

% rotation from Steer expressed in coordinate system frame (constant)
xRot = opti.variable(1,1);
yRot = opti.variable(1,1);
zRot = opti.variable(1,1);

% angle of the steer axis 
xRot2 = opti.variable(nfr,1);

% get rotation matrices for rotation steer in frame bike
Rx = rotx_casadi(xRot);
Ry = roty_casadi(yRot);
Rz = rotz_casadi(zRot);
R_ct = Rx*Ry*Rz; % constant rotation matrix from steer to frame

% rotation of steer in coordinate system frame (i.e. R_fr and R_st are
% expressed in world).
Rst_fr = nan(3,3,nfr);
for i =1:nfr
    Rst_fr(:,:,i) = R_fr(:,:,i)'*R_st(:,:,i);
end

J = 0;
for i =1:nfr
    R_steer =  R_ct' * Rst_fr(:,:,i);
    Error_R = R_steer - rotx_casadi(xRot2(i));
    J = J + sumsqr(Error_R);
end
opti.minimize(J);

% solver
options.ipopt.mu_strategy           = 'adaptive';
options.ipopt.max_iter              = 10000;
options.ipopt.linear_solver         = 'mumps';
options.ipopt.tol                   = 1*10^-6;
opti.solver('ipopt', options);
S = opti.solve();


%% get the output

% get the steer angle
qSteer = S.value(xRot2);
R_off = S.value(R_ct);

% compute the rotations in 3D
R_steer =  nan(3,3,nfr);
for i =1:nfr
    R_steer(:,:,i) =  R_off' * Rst_fr(:,:,i);
end

% get the steering angles
SteerAngles = rotm2eul(R_steer,'xyz');

%% plot figure
figure();
subplot(1,2,1)
plot(SteerAngles); hold on;
plot(qSteer,'--k');
legend('x','y','z');

