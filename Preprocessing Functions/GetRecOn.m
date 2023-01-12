
function [rec_on] = GetRecOn(rec_times)
    st = zeros(1,length(rec_times));
    st(rec_times > min(rec_times) + range(rec_times)/2) = 1;
    Dst = zeros(1,length(rec_times));
    dst = diff(st);
    indices = ceil(find(dst>0)*(30/30.3));
    ind =  [indices max(indices):indices(1):length(rec_times)];
    Dst(ind) = 1;
    rec_on = Dst;
end
