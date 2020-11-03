function [tTrigger,BoolSkipped,BoolError] = Control_Triggers(Data,tTrigger,nExpect,name)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


h = figure();

set(gcf,'Position',[109  151 1172  740]);

% n_Triggers = length(tTrigger);
TrialNames = {'Start','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};
CallNames = {'Call-person','Call-bike','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};
if nExpect == 12
    PhaseNames = CallNames;
else
    PhaseNames = TrialNames;
end

tTriggerInput = tTrigger;
h1 = subplot(2,1,1);
plot(Data.Frame.t,Data.Frame.QdWorld);
ylabel('Angular velocity [rad/s]');
Lines1 = vline(tTrigger,'--r');

for i =1:length(tTrigger)-1
    x = tTrigger(i);
    y = 2-i*0.3;
    Text1Vect(i)=text(x,y,PhaseNames{i});
end
set(gca,'YLim',[-3 3]);
set(gca,'Box','off');
title(name,'interpreter','none');


h2 = subplot(2,1,2);
plot(Data.Frame.t,Data.Frame.AccWorld);
ylabel('Angular acc [m/s2]');
xlabel('TIme [s]');
Lines2 = vline(tTrigger,'--r');
set(gca,'YLim',[-40 40]);
for i =1:length(tTrigger)-1
    x = tTrigger(i);
    y = 35-i*5;
    Text2Vect(i) = text(x,y,PhaseNames{i});
end
set(gca,'Box','off');

BoolSkipped = false;
BoolError = false;
% subplot(3,1,3)
% plot(Data.Trunk.t,Data.Trunk.AccWorld);
% ylabel('Angular acc - knee [m/s2]');
% xlabel('Time [s]');
% vline(tTrigger,'--r');
% set(gca,'YLim',[-30 30]);
% for i =1:length(tTrigger)-1
%    x = tTrigger(i);
%    y = 25-i*2;
%    text(x,y,PhaseNames{i});
% end
% set(gca,'Box','off');




% set the push buttons
handl.confrimbutton=uicontrol('String','OK',...
    'position',[20 10 100 40],...
    'style','togglebutton');
set(handl.confrimbutton,'Callback',{@confirm_function});

% Push button to add tTrigger
handl.confrimbutton=uicontrol('String','Add',...
    'position',[20 180 100 40],...
    'style','togglebutton');
set(handl.confrimbutton,'Callback',{@Add_function});

% Push button to remove tTrigger
handl.confrimbutton=uicontrol('String','Remove',...
    'position',[20 300 100 40],...
    'style','togglebutton');
set(handl.confrimbutton,'Callback',{@Remove_function});

% Push button to restore original
handl.confrimbutton=uicontrol('String','Original',...
    'position',[20 420 100 40],...
    'style','togglebutton');
set(handl.confrimbutton,'Callback',{@Restore_function});

% Labels-Callibration
handl.confrimbutton=uicontrol('String','Callibration',...
    'position',[20 540 100 40],...
    'style','togglebutton');
set(handl.confrimbutton,'Callback',{@CallibrationLabels});

% Labels-NoCallibration
handl.confrimbutton=uicontrol('String','No Callibration',...
    'position',[20 620 100 40],...
    'style','togglebutton');
set(handl.confrimbutton,'Callback',{@NormalLabels});

% Labels-NoCallibration
handl.confrimbutton=uicontrol('String','Skip',...
    'position',[20 700 100 40],...
    'style','togglebutton');
set(handl.confrimbutton,'Callback',{@Skip});

handl.confrimbutton=uicontrol('String','Error',...
    'position',[120 700 100 40],...
    'style','togglebutton');
set(handl.confrimbutton,'Callback',{@ErrorPush});

fig_bol=0;


% Functions
    function UpdatePlot(tTrigger,PhaseNames)
        axes(h1);
        % delete original lines
        for il = 1:length(Lines1)
            delete(Lines1(il))
        end
        for il = 1:length(Text1Vect)
            delete(Text1Vect(il))
        end
        Lines1 = vline(tTrigger,'--r');
        for jj =1:length(tTrigger)-1
            x = tTrigger(jj);
            y = 2-jj*0.3;
            Text1Vect(jj) = text(x,y,PhaseNames{jj});
        end
        %title(name);
        axes(h2);
        for il = 1:length(Lines2)
            delete(Lines2(il))
        end
        for il = 1:length(Text2Vect)
            delete(Text2Vect(il))
        end
        Lines2 = vline(tTrigger,'--r');
        set(gca,'YLim',[-40 40]);
        for jj =1:length(tTrigger)-1
            x = tTrigger(jj);
            y = 35-jj*5;
            Text2Vect(jj) = text(x,y,PhaseNames{jj});
        end
        
    end



% Interface
    function confirm_function( handle,eventdata)
        fig_bol=1;
    end




    function Remove_function( handle,eventdata)
        [x,y] = ginput(1);
        [~,iMin] = min(abs(tTrigger-x));
        tTrigger(iMin) = [];
        tTrigger = sort(tTrigger);
        
        % update the figure
        UpdatePlot(tTrigger,PhaseNames)
        fig_bol=0;
    end

    function Add_function( handle,eventdata)
        [x,y] = ginput(1);
        tTrigger = [tTrigger; x];
        tTrigger = sort(tTrigger);
        
        % update the figure
        UpdatePlot(tTrigger,PhaseNames)
        fig_bol=0;
    end

    function Restore_function( handle,eventdata)
        tTrigger = tTriggerInput;
        
        % update the figure
        UpdatePlot(tTrigger,PhaseNames)
        fig_bol=0;
    end

    function CallibrationLabels( handle,eventdata)
        PhaseNames = CallNames;
        UpdatePlot(tTrigger,PhaseNames);
        fig_bol=0;
    end

    function NormalLabels( handle,eventdata)
        % update the figure
        PhaseNames = TrialNames;
        UpdatePlot(tTrigger,PhaseNames);
        fig_bol=0;
    end

    function Skip( handle,eventdata)
        % update the figure
        BoolSkipped = true;
        fig_bol=1;
    end

    function ErrorPush( handle,eventdata)
        % update the figure
        BoolError = true;
        fig_bol=1;
    end

while fig_bol==0
    drawnow
end

close(h);



end

