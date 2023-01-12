clear Mode Fs setax Pos Ytick yaim X Y C cc ind frame f Frame v SI l q Raster wcc ax1 ax2 ax3 ax4 ax5 fig
%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROI Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
TOI = [0 120];
ROIt = 100*Ops.pctt.*TOI/120 + [1 0];
drec = Data.rec_on(1:ROIt(1));
drec = drec(drec > 0);
FirstFrame = sum(drec) + 1;
recsig = Data.rec_on(ROIt(1):ROIt(2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Make Video %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
mkdir([Ops.DataFolder filesep 'Videos']);
v = VideoWriter([Ops.DataFolder filesep 'Videos' filesep 'Rat_Treadmill_PPN_Stim']);
v.FrameRate = Ops.vfr;
v.Quality = 100;
open(v);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mode = 'Channels'; % Either 'Unit' or ' Channel' 
DisplayMode = 'BlackCenter';
DisplayVid = 'off';
%% Pre Process Data 
[cc,SI] = sort(Data.clusters_channels);
cc = cc+1;
Raster = Data.USpiking(ROIt(1):ROIt(2),SI)';
wcc = cc/max(cc);
C = ((1-wcc)*Colors().BergYellow + (wcc)*Colors().BergBlue);
%% Define Display Mode
switch Mode 
    case 'Units' 
         Pos =   0:size(Raster,1)-1;  
         Ytick = [1 size(Raster,1)]; 
         setax = 0;
    case 'Channels'
         Pos =  flipud(Data.chan_pos(cc,2));   
         Ytick = min(Data.chan_pos(cc,2)):80:max(Data.chan_pos(cc,2));
         setax = 1;
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
        [x1,y1,w1,h1] = ChangeCoordinates(0.03,0.05,0.05,0.90);
        ax1=axes('position',[x1,y1,w1,h1]);
        hold on 
        
        [x4,y4,w4,h4] = ChangeCoordinates(0.15,0.05,0.80,0.5);
        ax3 = axes('position',[x4,y4,w4,h4]);
        
        [x2,y2,w2,h2] = ChangeCoordinates(0.15,0.6 ,0.80,0.35);
        ax2=axes('position',[x2,y2,w2,h2]);
        set(ax2,'linewidth',1.5)
end
set(fig, 'Visible',DisplayVid);

%%% Plot Raster

axes(ax2)
PlotRaster(flipud(Raster),'Colors',flipud(C),'Pos',Pos,'MarkerSize',3);
if(Ops.flagstim)
    [~,locs] =  findpeaks(abs(diff(Data.stim_on)));
    for n = 1:2:length(locs)-1 
        patch(ax2,[locs(n) locs(n+1) locs(n+1) locs(n)],[0 0 max(ax2.YLim) max(ax2.YLim)],[0 0 0],'FaceAlpha',0.3,'FaceColor','white','EdgeColor','white')
    end
end
set(gca,'Color','none')
yticks(Ytick);
yticklabels(Ytick);
ylabel('Nth - Neuron','Color','White','FontSize',12);
xticks(0:5*Ops.fs:size(Raster,2));
xticklabels(0:5:size(Raster,2)/Ops.fs);
xlabel('Time [s]','Color','White','FontSize',12);
box(gca,'off')
axis([ 0 size(Raster,2) 0 size(Raster,1)])
ax2.YColor = 'White';
ax2.XColor = 'White';

%%% Plot Electrode
axes(ax1)
for q = 1:length(Data.chan_pos)
    patch(ax1,[Data.chan_pos(q,1)-10 Data.chan_pos(q,1)+10 Data.chan_pos(q,1)+10 Data.chan_pos(q,1)-10],[Data.chan_pos(q,2)-10 Data.chan_pos(q,2)-10 Data.chan_pos(q,2)+10 Data.chan_pos(q,2)+10],[0 0 0],'FaceAlpha',0.5,'FaceColor','w')
end
axis equal
axis off

if(setax)
    set(ax2,'YLim',ax1.YLim)
else
    set(ax2, 'YDir','reverse')
    set(ax2,'YLim',1.05*ax2.YLim)
end   

%%% Update Visuals and Save Video
Frame = 0;
for l = 1:length(recsig)
    ind = logical(Raster(:,l));
    X = Data.chan_pos(cc(ind),1);
    Y = Data.chan_pos(cc(ind),2);
    C = Colors().BergBlue.*wcc(ind) + Colors().BergYellow.*(1-wcc(ind));
    if(~isempty(X))
        scatter(ax1,X,Y,100,C,'filled','MarkerFaceAlpha',0.5);
    end
    if(l == 1 || (recsig(l) > 0))
        %%%% Update Video Plot
        frame = read(Data.Video,FirstFrame+Frame);
        image(frame, 'Parent', ax3);
        ax3.Visible = 'off';
        
        %%%% Update Line in Raster Plot
        plot(ax2,[l l],ax2.YLim ,'Color',Colors().BergGray02, 'LineWidth', 3);
        
        %%%% Force ploting and Save
        drawnow;
        f = getframe(fig);
        writeVideo(v,f);
        delete(findall(ax1,'Type','Scatter'));
        delete(findall(ax2,'Type','Line'));
        Frame = Frame + 1;
    end
end     

%%% End Video delete tempfiles
close(v)
close all
clear Mode Fs setax Pos Ytick yaim X Y C cc ind frame f Frame v SI l q Raster wcc