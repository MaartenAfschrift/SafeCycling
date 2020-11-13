function [OrderEvents,BoolError] = DetectEvents_FullTurnBased(Data,tTrigger)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
BoolError = 0;
if length(tTrigger) == 12
    OrderEvents     = {'Call-person','Call-bike','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};
    qdFrame = Data.Frame.QdWorld(:,3);
    t = Data.Frame.t;
    qdVect =nan(length(tTrigger)-1,1);
    for i =1:length(tTrigger)-1
        iSel = t<=tTrigger(i+1) & t>=tTrigger(i);
        qdVect(i) = nanmean(qdFrame(iSel));
    end
    [~,iMax] = max(qdVect);
    iTurn = find(strcmp(OrderEvents,'FullTurn'));
    if iMax ~= iTurn
        BoolError=1;
        if iMax + 1 == iTurn
            % only one pulse for start, no callibration phase here
            OrderEvents     = {'Start','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};
            % there is a double click somwhere else
            %    - mainly one click too much during walking
            %    - or one click too much during single hand
            disp('Full turn should be one phase later, removed first callibration phase');
        else
            disp('Unkown problem');
        end
    end
else
    OrderEvents     = {'Start','small','slalom','obstacles','FullTurn','Walk','DualTask','onehand','AfterDrop','brake','add1','add2'};
end


end

