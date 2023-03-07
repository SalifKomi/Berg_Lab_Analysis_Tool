clear Mode Fs setax Pos Ytick yaim X Y C cc ind frame f Frame v SI l q Raster wcc ax1 ax2 ax3 ax4 ax5 fig
%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROI Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
L = length(Data.rec_times)/Ops.fs;
TOI = [88.5 L-2];
ROIt = (100*Ops.pctt)*(TOI/L) + [1 0];
drec = Data.rec_on(1:ROIt(1));
drec = drec(drec > 0);
FirstFrame = sum(drec) + 1;
recsig = Data.rec_on(ROIt(1):ROIt(2));
stimsig = Data.stim_on(ROIt(1):ROIt(2));
Acc = Data.Acc(ROIt(1):ROIt(2),3);
NeuralCor = Data.Neural(ROIt(1):ROIt(2),[1,3,5]);
NeuralHyp = Data.Neural(ROIt(1):ROIt(2),[2,4,6,7]);
NeuralHyp =  NeuralHyp(:,2);%- NeuralHyp(:,3);
NeuralCor =  NeuralCor(:,2);% - mean(NeuralCor,2);

res = 20000;
NormRes = (Ops.fs)/(res);
Spectrum = spectrogram(NeuralHyp,5000,4900,res,Ops.fs,'yaxis');
BandOI = [5 9] ;
IntervOI  = [BandOI(1):NormRes:BandOI(2)]/(NormRes);

DisplayBand = [0 20];
DisplayInterv = [DisplayBand(1):NormRes:DisplayBand(2)]/(NormRes);

EnvAcc = movmean(abs(Acc),Ops.fs);
EnvNeurHyp = sum(abs(Spectrum(1:IntervOI(end),:)),1);

EnvNeurHyp = resampc(length(EnvNeurHyp),EnvNeurHyp',length(EnvAcc),'Type','linear');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Make Video %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
mkdir([Ops.DataFolder filesep 'Videos']);
v = VideoWriter([Ops.DataFolder filesep 'Videos' filesep 'Rat_Treadmill_Theta_PPN_Stim']);
v.FrameRate = Ops.vfr;
v.Quality = 50;
open(v);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        fig = figure('Position',[0,0,Ops.screensize(3)/2.2, Ops.screensize(4)/1],'Color',[0 0 0]);
        
        [x1,y1,w1,h1] =  ChangeCoordinates(0.05,0.6 ,0.80,0.15);
        ax1=axes('position',[x1,y1,w1,h1]);
        hold on 
        
        [x4,y4,w4,h4] = ChangeCoordinates(0.05,0.05,0.80,0.6);
        ax3 = axes('position',[x4,y4,w4,h4]);
        
        [x2,y2,w2,h2] = ChangeCoordinates(0.05,0.80 ,0.80,0.15);
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
    for n = 1:2:length(locs)-1 
        patch(ax2,[locs(n) locs(n+1) locs(n+1) locs(n)],[min(ax2.YLim) min(ax2.YLim) max(ax2.YLim) max(ax2.YLim)],[0 0 0],'FaceAlpha',0.3,'FaceColor',(0.1*Colors().BergBlue+0.9*[1 1 1]),'EdgeColor','white')
    end
end

%%% Plot Electrode
axes(ax1)
imagesc(abs(Spectrum(1:DisplayInterv(end),:)))
colormap('hot')
yticks([0:5/NormRes:max(DisplayInterv)]);
yticklabels([0:5:max(DisplayBand)]);
ylabel('Frequency [Hz]','Color','White','FontSize',12);
box(gca,'off')
ax1.YColor = 'White';
ax1.XColor = 'none';
axis tight
caxis([0.12 1].*max(abs(Spectrum),[],'all'))

%%% Update Visuals and Save Video
Frame = 0;
for l = 1:length(recsig)
    if(l == 1 || (recsig(l) > 0))
        %%%% Update Video Plot
        frame = read(Data.Video,FirstFrame+Frame);
        image(frame, 'Parent', ax3);
        ax3.Visible = 'off';
        
        if(logical(stimsig(l)))
            t1 = text(ax3,0.9*size(frame,2),0.9*size(frame,1),'Stim ON','Color','White','FontSize',14);
        end
        %%%% Update Line in Raster Plot
        l1 = plot(ax2,[l l],ax2.YLim ,'Color',Colors().BergGray02, 'LineWidth', 3);
        
        %%%% Force ploting and Save
        drawnow;
        f = getframe(fig);
        writeVideo(v,f);
        delete(l1);
        if(exist('t1'))
            delete(t1);
        end
        Frame = Frame + 1;
    end
end     

%%% End Video delete tempfiles
close(v)
close all
clear Mode Fs setax Pos Ytick yaim X Y C cc ind frame f Frame v SI l q Raster wcc