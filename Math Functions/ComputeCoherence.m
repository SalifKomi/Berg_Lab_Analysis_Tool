function [coh_mag, coh_angle, peakfreq2] = ComputeCoherence(trace_a,trace_b,num_win,ddt,paddingtimes)
% This function calculated the power spectrum with proper normalization, so
% that if the signal is given in volts, the value is truely the power.
% In addition it use multitaper to window the data, and thereafter performs
% a padding. 5 times padding is usually enough.

%%
npp=length(trace_a);
windows=dpss(npp,num_win/2);
fs=1./(ddt)   ;% Maximum frequency with unit is Hz
fmax=1./(2*ddt)   ;% Maximum frequency with unit is Hz

trace_aa=(trace_a-mean(trace_a));
trace_bb=(trace_b-mean(trace_b));

for i=1:num_win
    aa1=fft(padding(trace_bb.*windows(:,i),paddingtimes));
    aa2=fft(padding(trace_aa.*windows(:,i),paddingtimes));
    bb1=conj(aa1);
    bb2=conj(aa2);
    
    S12_a(:,i)= aa1.*bb2;
    S11_a(:,i)= aa1.*bb1;
    S22_a(:,i)= aa2.*bb2;
end

S12a=sum(S12_a,2) ;    %taking the average of estimates using different windows
S11a=sum(S11_a,2) ;    %taking the average of estimates using different windows
S22a=sum(S22_a,2) ;    %taking the average of estimates using different windows

newnpp=size(S12_a,1);
S12=S12a(1:round(newnpp/2))   ;    % Disregarding the negative frequencies.
S11=S11a(1:round(newnpp/2))   ;    % Disregarding the negative frequencies.
S22=S22a(1:round(newnpp/2))   ;    % Disregarding the negative frequencies.

coh=S12./((S11.*S22).^.5);

freqa=0:round((newnpp/2)-1);
factor=fmax./round((newnpp/2)-1);
freq=freqa*factor;

setfreq= find(freq > .4) ;
peakfreq2=setfreq(find(S22(setfreq) == max(S22(setfreq))));

coh_angle=angle(coh(peakfreq2));
coh_mag=abs(coh(peakfreq2));

function out=padding(xx,ntimes)
% this function add zeros around the trace xx, so that is is ntimes the
% original length. The mean of the trace is also removed.
% Rune W. Berg 2008
xx=xx-mean(xx); np=length(xx); xxp(1:np)=xx;
if ntimes > 0
    xxp(np+1:ntimes*np)=0;
end
out=xxp;

