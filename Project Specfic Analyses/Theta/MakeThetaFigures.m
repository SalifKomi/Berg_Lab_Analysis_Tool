clear Mode Fs setax Pos Ytick yaim X Y C cc ind frame f Frame v SI l q Raster wcc ax1 ax2 ax3 ax4 ax5 fig
load('Blue_ice.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROI Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
L = length(Data.rec_times)/Ops.fs;
TOI = [0 L-2];
ROIt = (100*Ops.pctt)*(TOI/L) + [1 0];
drec = Data.rec_on(1:ROIt(1));
drec = drec(drec > 0);
FirstFrame = sum(drec) + 1;
recsig = Data.rec_on(ROIt(1):ROIt(2));

stimsig = Data.stim_on(ROIt(1):ROIt(2));
prestimsig = circshift(stimsig,-Ops.fs/2); prestimsig(end-Ops.fs/2:end) = 0;
diffsig = (stimsig|prestimsig);
StimW = SplitVec(find(diffsig),'consecutive');

Acc = Data.Acc(ROIt(1):ROIt(2),3);
NeuralHyp = Data.Neural(ROIt(1):ROIt(2),:);
NeuralCor = Data.Neural(ROIt(1):ROIt(2),[2,4,6,7]);
NeuralHyp =  NeuralHyp(:,1);%- NeuralHyp(:,4);
NeuralCor =  NeuralCor(:,2);% - mean(NeuralCor,2);

res = 20000;
NormRes = (Ops.fs)/(res);
Spectrum = spectrogram(NeuralHyp,5000,4990,res,Ops.fs,'yaxis');
BandOI = [5 15] ;
IntervOI  = [BandOI(1):NormRes:BandOI(2)]/(NormRes);

DisplayBand = [0 30];
DisplayInterv = [DisplayBand(1):NormRes:DisplayBand(2)]/(NormRes);

EnvAcc = movmean(abs(Acc),500);
EnvNeurHyp = sum(abs(Spectrum(1:IntervOI(end),:)),1);
EnvNeurHyp = resampc(length(EnvNeurHyp),EnvNeurHyp',length(EnvAcc),'Type','linear');

%%
figure 
cellfun(@(x) PlotWindow(EnvAcc,x,Ops,'Color',Colors().BergGray05),StimW);
hold on 
cellfun(@(x) PlotWindow(EnvNeurHyp,x,Ops,'Color',Colors().BergBlue),StimW);
ax = gca;
plot([Ops.fs/2 Ops.fs/2],ax.YLim,'--r');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mode = 'Units'; % Either 'Unit' or ' Channel' 
DisplayMode = 'BlackCenter';
DisplayVid = 'off';
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
        fig = figure('Position',[0,0,Ops.screensize(3)/2.2, Ops.screensize(4)/3],'Color',[0 0 0]);
        
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
end
set(fig, 'Visible',DisplayVid);

%%% Plot Raster

axes(ax2)
plot(Acc,'w')
set(gca,'Color','none')
yticks(Ytick);
yticklabels(Ytick);
ylabel('Acceleration [A.U]','Color','White','FontSize',12);
xticks(0:5*Ops.fs:size(Acc,1));
xticklabels(0:5:size(Acc,1)/Ops.fs);
xlabel('Time [s]','Color','White','FontSize',12);
box(gca,'off')
axis([ 0 size(Acc,1) 1.25*min(Acc) 1.25*max(Acc)])
ax2.YColor = 'White';
ax2.XColor = 'White';
title('Accelerometers')
hold on

if(Ops.flagstim)
    [~,locs] =  findpeaks(abs(diff(stimsig)));
    for n = 2:2:length(locs)-1 
        patch(ax2,[locs(n) locs(n+1) locs(n+1) locs(n)],[min(ax2.YLim) min(ax2.YLim) max(ax2.YLim) max(ax2.YLim)],[0 0 0],'FaceAlpha',0.3,'FaceColor',(0.1*Colors().BergBlue+0.9*[1 1 1]),'EdgeColor','white')
    end
end

%%% Plot Electrode
axes(ax1)
imagesc(abs(Spectrum(1:DisplayInterv(end),:)))
colormap(Blue_ice)
yticks([0:5/NormRes:max(DisplayInterv)]);
yticklabels([0:5:max(DisplayBand)]);
ylabel('Frequency [Hz]','Color','White','FontSize',12);
box(gca,'off')
ax1.YColor = 'White';
ax1.XColor = 'none';
axis tight
caxis([0.12 1].*max(abs(Spectrum),[],'all'))


%%
function  [tauSpec, tauAcc] = FitAndQuantifDecay(Spec,Acc,Ops,window)
    toi = (Ops.fs/2):max(Ops.fs,length(window));    
    fspec = fit(toi,Spec(window(toi)),'exp1');
    facc = fit(toi,Spec(window(toi)),'exp1');
    
    tauSpec = fspec.b;
    tauAcc = facc.b;
end

%% 
function PlotWindow(Data,window,Ops,varargin)
C = [Colors().BergGray05];
for ii = 1:2:length(varargin)
    switch(varargin{ii})
        case 'Color'
            C = varargin{ii+1};
    end 
end
    plot(Data(window(1:max(Ops.fs,length(window))))/range(Data),'LineWidth',2,'Color',[C 0.5]);
    hold on
end
