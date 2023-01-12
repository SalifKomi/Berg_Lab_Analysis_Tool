function [PCA,Cycles] = GetKinematicCycles(KinCoord,interval,fs)

%% Compute PC horizontal position with respect to the hip
% Computing position variable
fc = 10;
[b,a] = butter(3,fc/(fs/2),'Low');
KinCoord = filtfilt(b,a,KinCoord);
s = KinCoord(:,1)-KinCoord(:,9);
Smov = s(:,1) - movmean(s(:,1),0.75*fs);

%% Initialize Parameters
n=1;
Cycles = struct();
%% Start Event Detection
PCA = Smov;
[~,IndS] = findpeaks(abs(PCA),'MinPeakHeight',std(PCA)/2,'MinPeakDistance',1000);
for j = IndS'
    if PCA(j) < 0 
        Cycles.Start(n) = j;
    elseif PCA(j) > 0 
        Cycles.End(n) = j;
    end
    n = n+1; 
end

