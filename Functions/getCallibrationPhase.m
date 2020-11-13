function [timeSpan] = getCallibrationPhase(t,dt,QdWorld)
%getCallibrationPhase Uses a treshold based method to identify the
%callibration phase (based on the angular velocity in the world frame).
%   Detailed explanation goes here


iSel = find(t<dt(2) &  t>dt(1));
qd = QdWorld(iSel,3);
% get average of absolute value per second
qd_mAv=movmean(abs(qd),100,'omitnan' ); % 100 hz -> 1 second data
iCal = qd_mAv >1; % trehsold of 1 rad/s
if isempty(iCal) || sum(iCal)<200
    ct = 0;
    while sum(iCal) < 200 % at least 2 seconds of data
        iCal = qd_mAv > (1 - 0.01*ct);
        ct = ct+1;
    end
end
tCal = t(iSel(iCal));
timeSpan = [tCal(1) tCal(end)];




end

