%% Implementation based on SARA method

clear all; close all; clc;

% data with example of one callibration 
% load('ExampleData.mat','t','R_fr','R_st');
load('normal_data.mat');
% select indices of callibration
dt = [17 44];
% dt = [1 150];
iFrame = Data.Frame.t>=dt(1) & Data.Frame.t<=dt(2);
iSteer = Data.Steer.t>=dt(1) & Data.Steer.t<=dt(2);

% get the rotation matrices
R_fr = Data.Frame.R(:,:,iFrame);
R_st = Data.Steer.R(:,:,iSteer);
t = Data.Frame.t(iFrame);

% get rotation matrix with "the steer" expressed in "bike frame" coordinate
% system
nfr = length(t);
Rst_fr = nan(3,3,nfr);
for i =1:nfr
    Rst_fr(:,:,i) = R_fr(:,:,i)'*R_st(:,:,i); %
end

% Create matrix A as in Zehr2007 (equation 2) with both the steer and the
% bike frame expressed in the world coordinate system
A = zeros(nfr*3,6);
for i = 1:nfr   
    A((i-1)*3+1 : i*3 , 1:3) = R_fr(:,:,i); % rotation matrix steer
    A((i-1)*3+1 : i*3 , 4:6) = -R_st(:,:,i); % rotation matrix  frame   
end


% singular value decomposition on matrix A (I don't fully understand this
% step)
[U, S, V]=svd(A,0); % singular value decomposition (A = U*S*V')

% get the orientation in steer and frame (I not following here as well)
n_frame = V(1:3,6)/norm(V(1:3,6)); %orientation in steer
n_steer = V(4:6,6)/norm(V(4:6,6)); %orientation in frame

%Compute the residuals 
errorFrame = nan(nfr,3);
for i=1:nfr
   errorFrame(i,:)  = eye(3)*n_frame -  Rst_fr(:,:,i)*n_steer;
end
figure(); 
plot(errorFrame);
ylabel('Errors [radians ?]');
xlabel('frames');

% Create new axis in the "bike frame" such that the new x-axis point in the
% direction of n_frame. x-axis seems to be a good idea since this
% the largest component in n_frame)

% 2. Je kan ook je frame-assenstelsel herdefinieren. Stel x_new_in_frame = n
% (maar zou hiervoor de as nemen die al het dichtst bij n ligt). z_new_in_frame
% = n x y [0 1 0], en y_new_in_frame = z_new_in_frame x n.  Dan kan je daaruit
% rotatiematrix opstellen.  R_t = [x_new_in_frame  y_new_in_frame  z_new_in_frame]'
% (dus transformeren). Die dan met R_i vermenigvuldigen, R_t*R_i en dan kan je volgens 
% mij Eulerhoeken berekenen en zou je enkel een noemenswaardige rotatie rond x moeten vinden.

%%
import casadi.*
opti = casadi.Opti();

% rotation from Steer expressed in coordinate system frame (constant)
xRot = opti.variable(1,1);
yRot = opti.variable(1,1);
zRot = opti.variable(1,1);
% get rotation matrices for rotation steer in frame bike
Rx = rotx_casadi(xRot);
Ry = roty_casadi(yRot);
Rz = rotz_casadi(zRot);
R = Rx*Ry*Rz; % constant rotation matrix from steer to frame

J = sumsqr([1 0 0]' - R*n_frame);
opti.minimize(J);

% solver
options.ipopt.mu_strategy           = 'adaptive';
options.ipopt.max_iter              = 10000;
options.ipopt.linear_solver         = 'mumps';
options.ipopt.tol                   = 1*10^-6;
opti.solver('ipopt', options);
S = opti.solve();
R = S.value(R);


%% compute steer angle

R_Axis = nan(3,3,nfr);
for i =1:nfr
    R_Axis(:,:,i) = R*Rst_fr(:,:,i);
end
qAxis = rotm2eul(R_Axis,'XYZ');

figure(); plot(qAxis); 
legend('x','y','z');

%% compute steer angle during whole trial

% get the rotation matrices
R_fr = Data.Frame.R(:,:,:);
R_st = Data.Steer.R(:,:,:);
t = Data.Frame.t(:);

% get rotation matrix with "the steer" expressed in "bike frame" coordinate
% system
nfr = length(t);
Rst_fr = nan(3,3,nfr);
for i =1:nfr
    Rst_fr(:,:,i) = R_fr(:,:,i)'*R_st(:,:,i); %
end

% in new coordinate system
R_Axis = nan(3,3,nfr);
for i =1:nfr
    R_Axis(:,:,i) = R*Rst_fr(:,:,i);
end

% compute an plot euler angles
qAxis = rotm2eul(R_Axis,'XYZ');
figure(); plot(qAxis); 
legend('x','y','z');







% %% Rotations around steer angles
% qd_st1 = QdSteer*n_steer;
% qd_st2 = QdFrame*n_frame;
% qdSteer = qd_st1-qd_st2;
% 
% figure(); 
% 
% subplot(3,1,1)
% plot(QdSteer);
% subplot(3,1,2)
% plot(QdFrame);
% subplot(3,1,3)
% plot(qd_st1,'r'); hold on;
% plot(qd_st2,'b');
% plot(qdSteer,'k','LineWidth',2);


