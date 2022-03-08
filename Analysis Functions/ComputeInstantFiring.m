%% Function Library
function [IFiring] = ComputeInstantFiring(SpikingEventT)
%% Set Differentiation Parameters
d = 1:max(SpikingEventT);
e = [1; sort(SpikingEventT,'ascend')];
IFiring = [];
ind = 2;
for i = d;
    if(i > e(ind))
        ind = ind+1;
    end
    IFiring = [IFiring ; 1/(e(ind) - e(ind-1))];
end