function [SlalomInfo] = GetSlalomInfo(filename)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

opts = spreadsheetImportOptions('NumVariables',32);
opts.DataRange = 'K54:AP94';
opts.Sheet = 'Info-Oud';
DatOlder = readcell(filename,opts);
DatOlder = cell2mat(DatOlder );

opts = spreadsheetImportOptions('NumVariables',32);
opts.DataRange = 'K53:AP53';
opts.Sheet = 'Info-Oud';
HeadersOlder = readcell(filename,opts);

opts = spreadsheetImportOptions('NumVariables',32);
opts.DataRange = 'M53:AR92';
opts.Sheet = 'Info-Jong';
DatYoung= readcell(filename,opts);
DatYoung = cell2mat(DatYoung );

opts = spreadsheetImportOptions('NumVariables',32);
opts.DataRange = 'M52:AR52';
opts.Sheet = 'Info-Jong';
HeadersYoung = readcell(filename,opts);

opts = spreadsheetImportOptions('NumVariables',1);
opts.DataRange = 'A5:A44';
opts.Sheet = 'Info-Jong';
ppIDYoung= readcell(filename,opts);
ppIDYoung = cell2mat(ppIDYoung);

opts = spreadsheetImportOptions('NumVariables',1);
opts.DataRange = 'A4:A44';
opts.Sheet = 'Info-Oud';
ppIDOld= readcell(filename,opts);
ppIDOld = cell2mat(ppIDOld);


SlalomInfo.DatYoung = DatYoung;
SlalomInfo.DatOlder = DatOlder;
SlalomInfo.HeadersOlder = HeadersOlder;
SlalomInfo.HeadersYoung = HeadersYoung;
SlalomInfo.ppIDYoung = ppIDYoung;
SlalomInfo.ppIDOld = ppIDOld;
end
