%% Function Library
function [IFiring] = ComputeInstantFiring(SpikingEventT,t_max)
%% Set Differentiation Parameters
d = 1:max(SpikingEventT);
e = [1; sort(SpikingEventT,'ascend')];
IFiring = zeros(t_max,1);
ind = 2;
for i = d;
    if(i > e(ind))
        ind = ind+1;
    end
    IFiring(i) = 1/(e(ind) - e(ind-1));
end