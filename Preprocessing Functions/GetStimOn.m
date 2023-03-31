
function [stim_on] = GetStimOn(stim_times,fs)
    stim_times = envelope(abs(diff(stim_times)),round(fs/20),'peak');
    stim_times(stim_times < 0) = 0;
    st = zeros(1,length(stim_times));
    st(stim_times > min(stim_times)+0.5*range(stim_times)) = 1;

    %st(stim_times > min(stim_times) + 1.2*std(stim_times)) = 1;
%     diff_stim_times = diff(st);
%     diff_pos = diff_stim_times;
%     diff_neg = -diff_pos;
%     diff_pos(diff_pos < 0) = 0;
%     diff_neg(diff_neg < 0) = 0;
%     diff_neg = diff_neg([length(diff_neg):-1:1]);
%     [~, posloc] = findpeaks(diff_pos,'MinPeakDistance',0.9*stim_interval*fs,'Threshold',max(diff_pos)/2);
%     [~, negloc] = findpeaks(diff_neg,'MinPeakDistance',0.9*stim_interval*fs,'Threshold',max(diff_neg)/2);
%     negloc = length(diff_neg) - negloc;
%     negloc = negloc([length(negloc):-1:1]);
%     stim_on = zeros(length(st),1); for i = 1:length(posloc); stim_on(posloc(i):negloc(i)) = 1; end
    stim_on = st;
end 
