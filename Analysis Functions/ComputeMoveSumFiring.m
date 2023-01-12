function [MSFiring,SpikeTrain] = ComputeMoveSumFiring(SpikingEventT,w,fs,t_max)

SpikeTrain = zeros(t_max,1);
SpikeTrain(SpikingEventT) = 1;
MSFiring = movsum(SpikeTrain,(w*fs)/1000);

end