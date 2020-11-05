function [TrigError,ListCall2] = getTriggerError()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


%% List with files with trigger errors:
ct = 1;
TrigError(ct).pp = 1;
TrigError(ct).Classic.CallTR2 = true;
ct = ct+1;

TrigError(ct).pp = 1;
TrigError(ct).EBike.CallTR2 = true;
ct = ct+1;

% visual check needed for this one
TrigError(ct).pp = 3;
TrigError(ct).Classic.Trial = [0 1 0]; 
TrigError(ct).Classic.Unkown = true;
ct = ct+1;

TrigError(ct).pp = 3;
TrigError(ct).EBike.CallTR2 = true;
ct = ct+1;

TrigError(ct).pp = 4;
TrigError(ct).EBike.Trial = [0 1 0];
TrigError(ct).EBike.AddPulse = true;
TrigError(ct).EBike.Note = 'add start rechtdoor fietsen';
ct = ct+1;


TrigError(ct).pp = 8;
TrigError(ct).EBike.Trial = [0 1 0];
TrigError(ct).EBike.AddPulse = true;
TrigError(ct).EBike.Note = 'add start slalom';
ct = ct+1;


TrigError(ct).pp = 17;
TrigError(ct).EBike.Trial = [1 0 0];
TrigError(ct).EBike.AddPulse = true;
TrigError(ct).EBike.Note = 'add start slalom';
ct = ct+1;


TrigError(ct).pp = 29;
TrigError(ct).EBike.Trial = [1 0 0];
TrigError(ct).EBike.AddPulse = true;
TrigError(ct).EBike.Note = 'add last pulse';
ct = ct+1;


TrigError(ct).pp = 35;
TrigError(ct).Classic.Trial = [0 0 1];
TrigError(ct).Classic.DeletePulse = true;
TrigError(ct).Classic.Note = 'subject did not hear first pulse for stopping, so additional';
ct = ct+1;


TrigError(ct).pp = 42;
TrigError(ct).Classic.Trial = [0 0 1];
TrigError(ct).Classic.DeletePulse = true;
TrigError(ct).Classic.Note = 'maybe delete pulse during walking';
ct = ct+1;


TrigError(ct).pp = 46;
TrigError(ct).EBike.Trial = [1 0 0];
TrigError(ct).EBike.AddPulse = true;
TrigError(ct).EBike.Note = 'add pulse Fullturn';
ct = ct+1;


TrigError(ct).pp = 57;
TrigError(ct).Classic.Trial = [0 0 1];
TrigError(ct).Classic.DeletePulse = true;
TrigError(ct).Classic.Note = 'extra pulse na Fullturn';
ct = ct+1;

TrigError(ct).pp = 64;
TrigError(ct).EBike.Trial = [1 0 0];
TrigError(ct).EBike.DeletePulse = true;
TrigError(ct).EBike.Note = 'extra pulse voor Fullturn';
ct = ct+1;


TrigError(ct).pp = 66;
TrigError(ct).EBike.Trial = [0 1 0];
TrigError(ct).EBike.DeletePulse = true;
TrigError(ct).EBike.Note = 'extra pulse na slalom';
ct = ct+1;


ListCall2 =[1 1 1;
    3 0 1;
    ];

end

