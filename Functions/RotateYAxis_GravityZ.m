function [yRot,Ry] = RotateYAxis_GravityZ(Acc)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% get norm acc
Acc_norm = Acc./sum(Acc,2);
nfr = length(Acc(:,1));
% create opti problem
import casadi.*
opti = casadi.Opti();
yRot = opti.variable(1,1);

% create rotation matrices
Ry = roty_casadi(yRot);

% rotate Acc with opt var
Acc_Rot = Acc_norm*Ry;

% objective function
J = sumsqr(Acc_Rot(:,1))./nfr + 0.0000001*yRot^2; % minimize acceleration around y-axis
opti.minimize(J);

% solver
options.ipopt.mu_strategy           = 'adaptive';
options.ipopt.max_iter              = 10000;
options.ipopt.linear_solver         = 'mumps';
options.ipopt.tol                   = 1*10^-6;
opti.solver('ipopt', options);
S = opti.solve();

% extract solution
yRot = value(S,yRot);
Ry = value(S,Ry);



end

