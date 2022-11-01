%% Function Library
function [IFiring] = ComputeInstantFiring(SpikingEventT,t_max,fs)
    %% Set Differentiation Parameters
    d = 1:max(SpikingEventT);
    e = [1; sort(SpikingEventT,'ascend')];
    IFiring = zeros(t_max,1);
    for I = 1:length(e)     
        if(I == 1)
                   IFiring(1:e(I)) = fs/(e(I) - 1);

        elseif (I == length(e))
                   IFiring(e(I):t_max) = 0;

        else
                   IFiring(e(I-1):e(I)) = fs/(e(I) - e(I-1));

        end
    end
end