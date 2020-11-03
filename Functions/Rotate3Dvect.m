function [out] = Rotate3Dvect(R,data)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[nfr,~] = size(data);
out = nan(size(data));
for i=1:nfr
    out(i,:) = squeeze(R(:,:,i))*data(i,:)';
end
end

