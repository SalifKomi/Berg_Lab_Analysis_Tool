function [out] = GetResampSig(epoch,q,varargin)

type = 'spline';
for ii=1:2:length(varargin)
    switch varargin{ii}
        case  'Type'
            type = varargin{ii+1};
        otherwise 
            error('Unknown argument');
    end
end

l = max(size(epoch));
p = 1:1:l;
xq = 1:l/q:l;
for k = 1:min(size(epoch))
    reEpoch = interp1(p,epoch(:,k),xq,type);
    if length(reEpoch) ~= q
        fill = reEpoch(end);
        ind = length(reEpoch);
        for j = 1:(q - length(reEpoch))
            reEpoch(ind+j) = fill;
        end
    end
    out(:,k)= reEpoch;
end
    