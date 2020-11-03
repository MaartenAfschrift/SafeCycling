function [R] = GetRotation_ForwardDirection(Rin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% % get norm acc
% Acc_norm = Acc./sum(Acc,2);
% nfr = length(Acc(:,1));
% 
% % create opti problem
% import casadi.*
% opti = casadi.Opti();
% xRot = opti.variable(1,1);
% zRot = opti.variable(1,1);
% 
% % create rotation matrices
% Rx = rotx_casadi(xRot);
% Rz = rotz_casadi(zRot);
% 
% % rotate Acc with opt var
% Acc_Rz = Acc_norm*Rz;
% Acc_Rx = Acc_Rz*Rx;
% 
% % objective function
% G = repmat([0 -1 0],nfr,1);
% J = sumsqr(G-Acc_Rx);
% opti.minimize(J);
% 
% % solver
% options.ipopt.mu_strategy           = 'adaptive';
% options.ipopt.max_iter              = 10000;
% options.ipopt.linear_solver         = 'mumps';
% options.ipopt.tol                   = 1*10^-6;
% opti.solver('ipopt', options);
% S = opti.solve();
% 
% % extract solution
% R = value(S,Rz)*value(S,Rx);


end

