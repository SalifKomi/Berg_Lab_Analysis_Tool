%% Function Library
function [GFiring] = ComputeGaussianFiring(SpikingEventT,w,fs)
%% Define Gaussian Window

t = -(fs/1000)*4*w:(fs/1000)*4*w;
kt = (1/sqrt(2*pi*(fs/1000)*w))*exp(-(t.^2/(2*((fs/1000)*w)^2)));
SpikeTrain = [];
SpikeTrain(SpikingEventT) = 1;
GFiring = conv(SpikeTrain,kt);
GFiring = GFiring((length(t)/2):end-(length(t)/2));