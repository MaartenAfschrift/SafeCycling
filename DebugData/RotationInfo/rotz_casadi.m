function [R] = rotz_casadi(gamma)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
R = [cos(gamma) -sin(gamma) 0; sin(gamma) cos(gamma) 0; 0 0 1];

end

