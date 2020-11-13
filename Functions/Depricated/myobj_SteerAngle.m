function [J] = myobj_SteerAngle(x,Rst_fr)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


Rx = rotx(x(1));
Ry = roty(x(2));
Rz = rotz(x(3));
R = Rx*Ry*Rz;


% qSteer = x(4:end);
nfr = length(Rst_fr(1,1,:));
Rsteer = nan(3,3,nfr);
for i=1:nfr
    Rsteer(:,:,i) = R'*Rst_fr(:,:,i);    
end
EulSteer = rotm2eul(Rsteer);
J = sumsqr(EulSteer(:,[1 3]));
% disp(J);







end

