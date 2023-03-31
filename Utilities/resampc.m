function [out] = resampc(l,epoch,q,varargin)

type = 'linear';
for ii=1:2:length(varargin)
    switch varargin{ii}
        case  'Type'
            type = varargin{ii+1};
        otherwise 
            error('Unknown argument');
    end
end


p = 1:1:l;
xq = 1:l/q:l;
for k = 1:size(epoch,2)
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
    
end