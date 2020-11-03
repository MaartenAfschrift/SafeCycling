function [h] = PlotDetailedFrame(Data,tTrigger,PhaseNames)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


figure();
subplot(2,1,1)
plot(Data.Frame.t,Data.Frame.QdWorld);
ylabel('Angular velocity [rad/s]');
vline(tTrigger,'--r');

for i =1:length(tTrigger)-1
   x = tTrigger(i);
   y = 2-i*0.1;
   text(x,y,PhaseNames{i});
end
set(gca,'YLim',[-3 3]);
set(gca,'Box','off');


subplot(2,1,2)
plot(Data.Frame.t,Data.Frame.AccWorld);
ylabel('Angular acc [m/s2]');
xlabel('TIme [s]');
vline(tTrigger,'--r');
set(gca,'YLim',[-30 30]);
for i =1:length(tTrigger)-1
   x = tTrigger(i);
   y = 25-i*2;
   text(x,y,PhaseNames{i});
end
set(gca,'Box','off');



end

