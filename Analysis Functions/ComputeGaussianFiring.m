%% Function Library
function [GFiring,SpikeTrain] = ComputeGaussianFiring(SpikingEventT,w,fs,ROI)

if(isempty(ROI))
     ME = MException('MyComponent:noSuchVariable','Variable %s not found','ROI');
     throw(ME)
end

%% Define Gaussian Window
theta = (w*fs)/1000;
t = -4*theta:theta*4;
kt = (1000/(sqrt(2*pi)*w))*exp(-(t.^2/(2*theta^2)));
SpikeTrain = zeros((ROI(2)-ROI(1)+1),1);
SpikingEventT = SpikingEventT((SpikingEventT < ROI(2)) & (SpikingEventT > ROI(1)));
SpikeTrain(SpikingEventT-ROI(1)) = 1;
GFiring = conv(kt,SpikeTrain);
GFiring = GFiring((length(t)/2):length(GFiring)-(length(t)/2));
end