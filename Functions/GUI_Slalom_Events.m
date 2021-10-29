function [tStart,tEnd,BoolSkipped,BoolDrift] = GUI_Slalom_Events(Phases,name,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


h = figure();

if isempty(varargin)
    set(gcf,'Position',[109  151 1172  740]);
else
    set(gcf,'Position',varargin{1});
end

% Booleans
BoolSkipped = false;
BoolDrift = false;
tStart = NaN;
tEnd = NaN;


% figure with angular velocity frame
h1 = subplot(3,1,1);
plot(Phases.Frame.slalom.t,Phases.Frame.slalom.QdWorld(:,3),'LineWidth',2); hold on;
% plot(Phases.Trunk.DualTask.t,0,'--k','LineWidth',0.5);
ylabel('Angular velocity [rad/s]');
set(gca,'Box','off');
title(name,'interpreter','none');
Lines1 = vline(tStart,'--b');
Lines2 = vline(tEnd,'--r');

% figure with orientation frame
h2 = subplot(3,1,2);
if isfield(Phases,'Frame')
    Rtorso = Phases.Frame.slalom.R;
    ttorso = Phases.Frame.slalom.t;
    if ~isempty(Rtorso)
        [eulTorso] = GetEulAngles_ShoulderCheck(Rtorso);
        plot(ttorso,eulTorso(:,1),'r','LineWidth',2);
    end
    %     plot(ttorso,0,'--k','LineWidth',0.5); hold on;
end
ylabel('orientation frame');
xlabel('time [s]');
set(gca,'Box','off');
Lines1b = vline(tStart,'--b');
Lines2b = vline(tEnd,'--r');


% figure with steering angle
h3 = subplot(3,1,3);
if isfield(Phases,'SteerAngle')
    plot(Phases.SteerAngle.slalom.t,Phases.SteerAngle.slalom.qSteer(:,1),'b','LineWidth',2); hold on;
    plot(Phases.SteerAngle.slalom.t,Phases.SteerAngle.slalom.qSteer(:,1),'k','LineWidth',0.2);
end
ylabel('Steering angle');
xlabel('time [s]');
set(gca,'Box','off');

% OK
handl.OK=uicontrol('String','OK',...
    'position',[20 10 100 40],...
    'style','togglebutton');
set(handl.OK,'Callback',{@confirm_function});

% Skip file

handl.skip=uicontrol('String','Error',...
    'position',[20 80 100 40],...
    'style','togglebutton');
set(handl.skip,'Callback',{@Skip});

% set the push buttons

cbx_Drift  = uicontrol('Style','checkbox','String','Drift', ...
    'Value',0,'Position',[20 150 100 40],        ...
    'Callback',@checkBoxDrift,'FontSize',14);


offy =120;


% Push button to add start
handl.AddStart=uicontrol('String','AddStart',...
    'position',[20 180+offy 100 40],...
    'style','togglebutton');
set(handl.AddStart,'Callback',{@Add_Start});

% Push button to remove start
handl.RemoveStart=uicontrol('String','RemoveStart',...
    'position',[20 240+offy 100 40],...
    'style','togglebutton');
set(handl.RemoveStart,'Callback',{@Remove_Start});

% Push button to add start
handl.AddEnd=uicontrol('String','AddEnd',...
    'position',[20 420+offy 100 40],...
    'style','togglebutton');
set(handl.AddEnd,'Callback',{@Add_End});

% Push button to remove start
handl.RemoveEnd=uicontrol('String','RemoveEnd',...
    'position',[20 480+offy 100 40],...
    'style','togglebutton');
set(handl.RemoveEnd,'Callback',{@Remove_End});





% handl.drift=uicontrol('String','Drift',...
%     'position',[20 700 100 40],...
%     'style','togglebutton');
% set(handl.drift,'Callback',{@ErrorPush});

fig_bol=0;


% Functions
    function UpdatePlot(tStart,tEnd)
        axes(h1);
        % delete original lines
        for il = 1:length(Lines1)
            delete(Lines1(il))
        end
        Lines1 = vline(tStart,'--b');
        for il = 1:length(Lines2)
            delete(Lines2(il))
        end
        Lines2 = vline(tEnd,'--r');
        
        axes(h2);
        % delete original lines
        for il = 1:length(Lines1b)
            delete(Lines1b(il))
        end
        Lines1b = vline(tStart,'--b');
        for il = 1:length(Lines2b)
            delete(Lines2b(il))
        end
        Lines2b = vline(tEnd,'--r');
    end

% Interface
    function confirm_function( handle,eventdata)
        fig_bol=1;
    end

    function Remove_Start(handle,eventdata)
        tStart = NaN;
        
        % update the figure
        UpdatePlot(tStart,tEnd)
        fig_bol=0;
    end

    function Add_Start( handle,eventdata)
        [x,y] = ginput(1);
        tStart = x(1);
        
        % update the figure
        UpdatePlot(tStart,tEnd)
        fig_bol=0;
    end

    function Remove_End(handle,eventdata)
        tEnd = NaN;
        
        % update the figure
        UpdatePlot(tStart,tEnd)
        fig_bol=0;
    end

    function Add_End( handle,eventdata)
        [x,y] = ginput(1);
        tEnd = x(1);
        
        % update the figure
        UpdatePlot(tStart,tEnd)
        fig_bol=0;
    end

    function Skip( handle,eventdata)
        % update the figure
        BoolSkipped = true;
        fig_bol=1;
    end

    function ErrorPush( handle,eventdata)
        % update the figure
        BoolDrift = true;
    end

    function checkBoxDrift(handle, eventdata)
        BoolDrift = get(handle,'Value');
    end

while fig_bol==0
    drawnow
end

close(h);



end

