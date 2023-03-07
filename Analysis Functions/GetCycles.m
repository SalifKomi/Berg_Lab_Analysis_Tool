function [PC,Cycles] = GetCycles(s,interval,fs)

%% Compute PC horizontal position with respect to the hip
% Computing position variable

PC1mov = s(:,1) - movmean(s(:,1),0.75*fs);
PC2mov = s(:,2) - movmean(s(:,2),0.75*fs);
PC3mov = s(:,3) - movmean(s(:,3),0.75*fs);
PC = [PC1mov, PC2mov, PC3mov];

%% Initialize Parameters
n=1;
Cycles = struct();
%% Start Event Detection
PCA = diff(PC2mov-PC1mov);
[~,IndS] = findpeaks(abs(PCA),'MinPeakHeight',0.5*std(PCA),'MinPeakDistance',interval);
for j = IndS'
    if PCA(j) < 0 
        Cycles.Start(n) = j;
    elseif PCA(j) > 0 
        Cycles.End(n) = j;
    end
    n = n+1; 
end

