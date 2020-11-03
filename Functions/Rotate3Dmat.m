function [out] = Rotate3Dmat(data,R)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[~,~,nfr] = size(data);
out = nan(size(data));
for i=1:nfr
    out(:,:,i) = R*squeeze(data(:,:,i));
end
end

