function [h] = PlotDefaultFigures(Data,tTrigger)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


h = figure('Name','gyroscope');
try
    Loc = {'Steer','Frame','Trunk','KneeL','KneeR','Pelvis'};
    nsensor = length(Loc);
    for i=1:nsensor
        if ~isempty(Data.(Loc{i}).data)
            subplot(2,3,i)
            plot(Data.(Loc{i}).t,Data.(Loc{i}).QdWorld);
            title(Loc{i})
            xlabel('time [s]');
            ylabel('angular velocity [deg/s]');
            vline(tTrigger,'--r');
            if i>3
                set(gca,'YLim',[-6 6]);
            end
        end
    end
    legend('x','y','z');
catch
end


end

