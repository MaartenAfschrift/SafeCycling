function [R,zRot,yRot] = GetRotation_StandingBalance(Acc)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% get norm acc
Acc_norm = Acc./sum(Acc,2);
nfr = length(Acc(:,1));

% create opti problem
import casadi.*
opti = casadi.Opti();
yRot = opti.variable(1,1);
zRot = opti.variable(1,1);

% create rotation matrices
Ry = roty_casadi(yRot);
Rz = rotz_casadi(zRot);

% rotate Acc with opt var
R = Ry*Rz;
Acc_Rot = Acc_norm*R;

% objective function
G = repmat([1 0 0],nfr,1); % we want that gravity points in upward direction along the z-axis
J = sumsqr(G-Acc_Rot)./nfr + 0.000001*sumsqr(yRot)^2 + + 0.000001*sumsqr(zRot)^2;
opti.minimize(J);

% solver
options.ipopt.hessian_approximation = 'limited-memory';
options.ipopt.mu_strategy           = 'adaptive';
options.ipopt.max_iter              = 10000;
options.ipopt.linear_solver         = 'mumps';
options.ipopt.tol                   = 1*10^-6;
options.ipopt.print_level           = 0;
opti.solver('ipopt', options);
S = opti.solve();

% extract solution
R = value(S,Ry)*value(S,Rz);
yRot = value(S,yRot);
zRot = value(S,zRot);



end

