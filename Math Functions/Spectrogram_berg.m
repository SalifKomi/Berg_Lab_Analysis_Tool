% Spectrogram
% Rune Berg
% This plots the spectrogram for time series for analyzing Jaspreets data :

function ComputeSpectrogram(sig,

trace1 = x_1 ;
time1= time_1;
np=length(trace1) ; 
Fc=4000 ;
paddingtimes=8;
num_win=2 ;

N=3;fs=1/si;

[b1,a1]=butter(N,2*Fc/(fs),'low');
temptrace2a=filter(b1,a1,trace1);

%winsize=10000 ; %Length of sliding window
%jumps=700;   %jumpsize
winsize=30000 ; %Length of sliding window
jumps=2000;   %jumpsize
%winsize=.5 ; % size of window in seconds

nppit=(np-winsize)/jumps

figure(10)
for i=1:nppit
    
display([num2str(round(100*i/nppit)) ' %'])
    c = Power_multi_traces(trace1((i-1)*jumps+1:(i-1)*jumps+winsize),num_win,si,paddingtimes) ;
    
    pxx(:,i)=c(:,2);
    pxx_sig(:,i)=c(:,3);
    timebase1(i)=mean(time1((i-1)*jumps+1:(i-1)*jumps+winsize)) ;

    subplot(211);plot(trace1((i-1)*jumps+1:(i-1)*jumps+winsize))
    subplot(212);plot(c(:,1), pxx(:,i) )
    xlim([0 20])
       drawnow
end
    freq=c(:,1);
%%
%minfreq=0;
%maxfreq=20;

minfreq=0;
maxfreq=50;

minfreq1=min(find(freq > minfreq))
maxfreq1=max(find(freq < maxfreq))


figure(4)
%ax2(1)=subplot(4,1,1);plot(time1, trace1);title(filename)
ax2(2)=subplot(4,1,2);surface(timebase1,freq(minfreq1:maxfreq1),(pxx(minfreq1:maxfreq1,:)),'EdgeColor','none'); title('Spectrogram')
%yticks([0 5 10 20])

ax2(3)=subplot(413);plot(   t_board_adc, board_adc_data);title('PPN stimulation + camera pulses')

ax2(4)=subplot(414);
plot(t_aux_input, aux_input_data(1,:)-mean(aux_input_data(1,:)),'color',[.5 .5 .5]);title('Accelerometer x,y,z'); hold on
plot(t_aux_input, aux_input_data(2,:)-mean(aux_input_data(2,:)),'color',[.5 .5 .5]);
plot(t_aux_input, aux_input_data(3,:)-mean(aux_input_data(3,:)),'color',[.5 .5 .5]);
ylim([-.3 .3])
%Caxes=[-1 1]; set(ax2(2),'CLim', Caxes) 
% ylim([0 30])
%xlim([8 21]); ylim([-dt*maxlag dt*maxlag])
linkaxes([ax2(4) ax2(3) ax2(2) ax2(1)],'x');
%colorbar('location','eastoutside');
%colorbar('hide');
xlim([min(time1) max(time1) ])
%colormap parula %default% window used.
colormap hot
%%


