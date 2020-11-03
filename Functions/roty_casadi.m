function [R] = roty_casadi(beta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
R = [cos(beta) 0 sin(beta); 0 1 0; -sin(beta) 0 cos(beta)];

end

