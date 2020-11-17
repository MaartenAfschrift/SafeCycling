function [tsel,qsel,BoolErrorFlag] = GetSteerAngleNarrowLane(Phases)
%GetDataNarrowLane Summary of this function goes here
%   Detailed explanation goes here


q = Phases.SteerAngle.small.qSteer(:,1); % steer angle aroud x-axis
t = Phases.SteerAngle.small.t;
eul = Phases.Frame.small.eul;
teul = Phases.Frame.small.t;

BoolErrorFlag = 0;

% get index turned
t0 = teul(1);
iTurned = find(eul(:,1) < 0,1,'first');
if isempty(iTurned)
    tend = teul(end); % just select end of file (indicates that trigger pulse was too early
%     disp(['possible error in file: ' filename ]);
    BoolErrorFlag = 1;
else
    % find last time the time derivative of the orientation is
    % is positive before iTurned
    deul_dt =  diff(eul(:,1))./diff(teul);
    iLastPosVel = find(deul_dt(1:iTurned,1)>0,1,'last');
    tend = teul(iLastPosVel);
end
% just select end of file (indicates that trigger pulse was too early
if isempty(tend)
    tend = teul(end);
    BoolErrorFlag = 1;
%     disp(['possible error in file: ' filename ])
end

% selecte indices
iSel = t>=t0 & t<=tend; % indices between start and end
qsel = q(iSel); % angle selected in time frame
tsel = t(iSel); % time vector selected


end

