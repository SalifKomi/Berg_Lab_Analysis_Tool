clear Mode Fs setax Pos Ytick yaim X Y C cc ind frame f Frame v SI l q Raster wcc ax1 ax2 ax3 ax4 ax5 fig
load('Blue_ice.mat')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mode = 'Units'; % Either 'Unit' or ' Channel' 
DisplayMode = 'WhiteCenter';
DisplayVid = 'off';
Save = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROI Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                                                                 
L = length(Data.rec_times)/Ops.fs;
TOI = [200 L-2];
ROIt = (100*Ops.pctt)*(TOI/L) + [1 0];

stimsig = Data.stim_on(ROIt(1):ROIt(2));
prestimsig = circshift(stimsig,-Ops.fs/2); prestimsig(end-Ops.fs/2:end) = 0;
diffsig = (stimsig|prestimsig);
StimW = SplitVec(find(diffsig),'consecutive');

Acc = Data.Acc(ROIt(1):ROIt(2),:);
NeuralHyp = Data.Neural(ROIt(1):ROIt(2),:);
NeuralCor = Data.Neural(ROIt(1):ROIt(2),[2,4,6,7]);
NeuralHyp =  NeuralHyp(:,7)-NeuralHyp(:,9)- mean(NeuralHyp(:,7:9),2); 
NeuralCor =  NeuralCor(:,2);% - mean(NeuralCor,2);

res = 20000;
NormRes = (Ops.fs)/(res);
[Spectrum,Frequencies] = ComputeBergSpectrogram(NeuralHyp,Ops);
Spectrum = Spectrum';
% Spectrum = spectrogram(NeuralHyp,5000,4990,res,Ops.fs,'yaxis');
%DisplayInterv = [DisplayBand(1):NormRes:DisplayBand(2)]/(NormRes);
%IntervOI  = [BandOI(1):NormRes:BandOI(2)]/(NormRes);

DisplayBand = [0 20];
BandOI = [5 10] ;                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

minfreqDisp = Frequencies > DisplayBand(1);
maxfreqDisp = Frequencies < DisplayBand(end);
DispOI = minfreqDisp & maxfreqDisp;

minfreqOI = Frequencies > BandOI(1);
maxfreqOI = Frequencies < BandOI(end);
IntervOI = minfreqOI & maxfreqOI;

DispSpectrum = Spectrum(:,DispOI);
QuantSpectrum = Spectrum(:,IntervOI);
                                      
DispSpectrum = resampc(size(DispSpectrum,1),DispSpectrum,length(NeuralHyp))';
QuantSpectrum = resampc(size(QuantSpectrum,1),QuantSpectrum,length(NeuralHyp))';

EnvAcc = movmean(sum(abs(Acc),2),5000);
EnvNeurHyp = sum(abs(QuantSpectrum),1)';
%EnvNeurHyp = movmean(EnvNeurHyp',50);

[tauneur, tauacc] = cellfun(@(x) FitAndQuantifDecay(EnvNeurHyp,EnvAcc,Ops,x),StimW);  
tauneur = rmoutliers(tauneur,'median');
tauacc = rmoutliers(tauacc,'median');
                                                                                 
%% Define Display Mode
switch Mode 
    case 'Units' 
         Pos =   0:size(Acc,1)-1;  
         Ytick = [1 size(Acc,1)]; 
end
%% %%%%%%%%%%%%%%%%%%%%%%%% START PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SET AXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch DisplayMode 
    case 'Background'
        [fig,~] = LoadBackgroundFigure();
        
        [x1,y1,w1,h1] = ChangeCoordinates(0.41,0.05,0.05,0.90);
        ax1=axes('position',[x1,y1,w1,h1]);
        hold on 
        
        [x4,y4,w4,h4] = ChangeCoordinates(0.48,0.05,0.5,0.5);
        ax3 = axes('position',[x4,y4,w4,h4]);
        
        [x2,y2,w2,h2] = ChangeCoordinates(0.48,0.6 ,0.5,0.35);
        ax2=axes('position',[x2,y2,w2,h2]);
        set(ax2,'linewidth',1.5)
        
    case 'BlackCenter'
        fig = figure('Position',[0,0,Ops.screensize(3)/3, Ops.screensize(4)/3],'Color',[0 0 0]);
        DisplayInterv
        [x4,y4,w4,h4] = ChangeCoordinates(0.7,0.05,0.25,0.425);
        ax4 = axes('position',[x4,y4,w4,h4]);
        
        [x3,y3,w3,h3] = ChangeCoordinates(0.7,0.525,0.25,0.425);
        ax3 = axes('position',[x3,y3,w3,h3]);
        
        [x1,y1,w1,h1] =  ChangeCoordinates(0.05,0.05 ,0.60,0.425);
        ax1=axes('position',[x1,y1,w1,h1]);
        hold on 
        [x2,y2,w2,h2] = ChangeCoordinates(0.05,0.525 ,0.60,0.425);
        ax2=axes('position',[x2,y2,w2,h2]);
        set(ax2,'linewidth',1.5)

    case 'WhiteCenter'
        fig = figure('Position',[0,0,Ops.screensize(3)/3, Ops.screensize(4)/3],'Color',[1 1 1]);
        
        [x4,y4,w4,h4] = ChangeCoordinates(0.7,0.05,0.25,0.425);
        ax4 = axes('position',[x4,y4,w4,h4]);
        
        [x3,y3,w3,h3] = ChangeCoordinates(0.7,0.525,0.25,0.425);
        ax3 = axes('position',[x3,y3,w3,h3]);
        
        [x1,y1,w1,h1] =  ChangeCoordinates(0.05,0.05 ,0.60,0.125);
        ax1=axes('position',[x1,y1,w1,h1]);
        hold on 
        [x2,y2,w2,h2] = ChangeCoordinates(0.05,0.225 ,0.60,0.725);
        ax2=axes('position',[x2,y2,w2,h2]);
        set(ax2,'linewidth',1.5)
end
set(fig, 'Visible',DisplayVid);


%%

axes(ax3)
cellfun(@(x) PlotWindow(EnvAcc,x,Ops,'Color',Colors().BergBlack),StimW);                                                                                   
hold on 
cellfun(@(x) PlotWindow(EnvNeurHyp,x,Ops,'Color',Colors().BergElectricBlue),StimW)
plot([Ops.fs/2 Ops.fs/2],ax3.YLim,'--','Color',Colors().BergOrange,'LineWidth',1);

set(ax3,'Color','none')
box(ax3,'off')
ax3.YColor = Colors().BergBlack;
ax3.XColor = Colors().BergBlack; 

axes(ax4)
hold on
patch(ax4,[0.75 1.25 1.25 0.75],[0 0 mean(tauneur) mean(tauneur)],[0 0 0],'FaceAlpha',0.5,'FaceColor',Colors().BergBlack,'EdgeColor',Colors().BergElectricBlue)
scatter(ones(length(tauneur)),tauneur,50,'o','filled','MarkerFaceColor',Colors().BergElectricBlue,'MarkerFaceAlpha',0.5,'MarkerEdgeColor',Colors().BergElectricBlue)
patch(ax4,[1.75 2.25 2.25 1.75],[0 0 mean(tauacc) mean(tauacc)],[0 0 0],'FaceAlpha',0.5,'FaceColor',Colors().BergBlack,'EdgeColor',Colors().BergWhite)
scatter(2*ones(length(tauacc)),tauacc,50,'o','filled','MarkerFaceColor',Colors().BergWhite,'MarkerFaceAlpha',0.5,'MarkerEdgeColor',Colors().BergWhite)

set(gca,'Color','none')
box(gca,'off')
ax4.YColor = Colors().BergBlack;
ax4.XColor = Colors().BergBlack;
xticks([1 2])
xticklabels({'Tau Theta','Tau Acc'})

ylabel('Tau [s]')

%%% Plot Raster

axes(ax2)
hold on
plot(Acc,'Color',[Colors().BergBlack 0.7])
plot(EnvNeurHyp);
set(gca,'Color','none')
yticks(Ytick);
yticklabels(Ytick);
ylabel('Acceleration [A.U]','Color',Colors().BergBlack,'FontSize',12);
xticks(0:5*Ops.fs:size(Acc,1));
xticklabels(0:5:size(Acc,1)/Ops.fs);
xlabel('Time [s]','Color',Colors().BergBlack,'FontSize',12);
box(gca,'off')
axis([ 0 size(Acc,1) 1.25*min(Acc(:)) 1.25*max(Acc(:))])
ax2.YColor = Colors().BergBlack;
ax2.XColor = Colors().BergBlack;
title('Accelerometers')
hold on

if(Ops.flagstim)
    [~,locs] =  findpeaks(abs(diff(stimsig)));
    for n = 1:2:length(locs)-1 
        patch(ax2,[locs(n) locs(n+1) locs(n+1) locs(n)],[min(ax2.YLim) min(ax2.YLim) max(ax2.YLim) max(ax2.YLim)],[0 0 0],'FaceAlpha',0.3,'FaceColor',(0.8*Colors().BergOrange+0.2*[1 1 1]),'EdgeColor',Colors().BergBlack)
    end
end

%%% Plot Electrode
axes(ax1)
imagesc(abs(DispSpectrum))
colormap(Blue_ice)
%yticks([Frequencies(DispOI)]);
%yticklabels([0:5:max(DisplayBand)]);
ylabel('Frequency [Hz]','Color',Colors().BergBlack,'FontSize',12);
box(gca,'off')
ax1.YColor = Colors().BergBlack;
ax1.XColor = 'none';
axis tight
caxis([0.1 1].*max(abs(DispSpectrum),[],'all'))

if(Save)
    save2pdf(fig,[Ops.DataFolder filesep 'Figures'],['TauEstimation_Rat30'],'-dpdf');
end

%%
function  [tauSpec, tauAcc] = FitAndQuantifDecay(Spec,Acc,Ops,window)
    toi = (Ops.fs/2):length(window)/2;    
    fspec = fit(toi',Spec(window(toi))-min(Spec(window(toi))),'exp1');
    facc = fit(toi',Acc(window(toi))-min(Acc(window(toi))),'exp1');
    tauSpec = abs(1/(fspec.b*Ops.fs));
    tauAcc = abs(1/(facc.b*Ops.fs));
end

%% 
function PlotWindow(Data,window,Ops,varargin)
C = [Colors().BergBlack];
for ii = 1:2:length(varargin)
    switch(varargin{ii})
        case 'Color'
            C = varargin{ii+1};
    end 
end
    plot((Data(window(1:length(window)))-min(Data(window(1:length(window)))))/range(Data(window(1:length(window)))),'LineWidth',2,'Color',[C 0.75]);
    hold on
end
