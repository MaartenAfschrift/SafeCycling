function [ delete_number ] = Data_controller(input_signal,standard_signal,stand,input_title)
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here
%CONTROLE_EMG_SIGNAL plots the values of a matrix with input signals and
%plots an input "golden standard" signal. You can remove the "bad" input
%signals.
%   INPUT: => controle_emg_signal(input_signal,standard_signal,stand,input_name)
%          -1: input signal= matrix where each signal is an column vector
%          -2: standard_signal= an column vector with the golden standard
%          signal
%          -3: stand= a column vector with the std of the golden stadard
%          signal
%          -4: input_title= the name of the input variable ( shown in the
%          title of the plot)
%          - varargin{1}=> do not change gold standard; varargin{1}=1;

h=figure();

% initialise the delete number
if ~exist('delete_number');
    delete_number=[];
    count_delete_number=1;
end

% plot figure
set(gcf,'Position',get(0,'ScreenSize'))
n_signals=length(input_signal(1,:));
colors=jet(n_signals);
x=1:length(input_signal);
for i=1:length(input_signal(1,:))
    h_line(i)=plot(x,input_signal(:,i),'color',colors(i,:));
    hold on
end
H_gold=shadedErrorBar(x',standard_signal,stand);

% create the legend and title
for i=1:length(input_signal(1,:))
    legend_cell{i}=['input channel: ' num2str(i)];
end

legend_cell{length(legend_cell)+1}='average_signal';
legend(legend_cell,'Location','Best');
title(input_title,'interpreter','none');
fig_bol=0;

% set the push buttons
handl.confrimbutton=uicontrol('String','OK',...
    'position',[20 30 150 60],...
    'style','togglebutton');
set(handl.confrimbutton,'Callback',{@confirm_function});

% calculate the size of the buttons (this depends on the number of signals)
n_buttons=n_signals;
screen=get(0,'Screensize');
hor_screen=screen(3);
vert_screen=screen(4);

vert_space=vert_screen-200;
room_between=vert_space/(n_buttons+1);
size_button=room_between*0.6;


for i=1:length(input_signal(1,:))
    handl.changebut=uicontrol('String',['NaN: ' num2str(i)],...
        'position',[20 100+i*room_between 100 size_button],...
        'style','togglebutton');
    
    handl.restbut=uicontrol('String',['Restore: ' num2str(i)],...
        'position',[140 100+i*room_between 100 size_button],...
        'style','togglebutton');
    %     set(handl.changebut(i),'Callback',{@change_function,i,h_line,count_delete_number,delete_number});
    set(handl.changebut,'Callback',{@change_function,i});
    set(handl.restbut,'Callback',{@restore_function,i});
end



    function confirm_function( handle,eventdata)
        fig_bol=1;
    end

    function change_function(hanlde,eventdata,number)
        %input_signal(:,number)=NaN(length(input_signal_sel),1);
        delete_number(count_delete_number)=number;
        count_delete_number=count_delete_number+1;
        delete(h_line(number));
        if length(varargin)>1 && varargin{1}==1
            % don't change the shaded errorbar
        else
            delete(H_gold.mainLine);delete(H_gold.edge);delete(H_gold.patch);
            indices_selected=1:n_signals;
            for kk=1:length(delete_number)
                indices_selected=indices_selected(indices_selected~=delete_number(kk));
            end
            H_gold=shadedErrorBar(x',nanmean(input_signal(:,indices_selected)'),nanstd(input_signal(:,indices_selected)'));
        end
        
        fig_bol=0;
    end
    function restore_function(hanlde,eventdata,number)
        %input_signal(:,number)=NaN(length(input_signal_sel),1);
        % if construction for safety (restore first)
        if ~isempty(delete_number)
            delete_number(delete_number==number)=[];
            count_delete_number=count_delete_number-1;
            hold on
            h_line(number)=plot(input_signal(:,number),'color',colors(number,:));
            if length(varargin)>1 && varargin{1}==1
                % don't change the shaded errorbar
            else
                delete(H_gold.mainLine);delete(H_gold.edge);delete(H_gold.patch);
                indices_selected=1:n_signals;
                for kk=1:length(delete_number)
                    indices_selected=indices_selected(indices_selected~=delete_number(kk));
                end
                H_gold=shadedErrorBar(x',nanmean(input_signal(:,indices_selected)'),nanstd(input_signal(:,indices_selected)'));
            end
        end
        fig_bol=0;
    end

while fig_bol==0;
    drawnow
end

close(h)

end



