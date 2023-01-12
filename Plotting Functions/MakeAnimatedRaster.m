clearvars -except Data Ops Folder
%%
mkdir([Ops.DataFolder filesep 'Videos']);
v = VideoWriter([Ops.DataFolder filesep 'Videos' filesep 'PCDynamics']);
v.FrameRate = 25;
v.Quality = 100;
open(v);
%% Plot Spatial PC
pctt = double(length(Data.UFiring)/100); % Percent of the recording duration
pcts = double(ceil(range(Data.chan_pos(:,2))/100)); % spatial percentage

ROIt = pctt.*[82.08 87.5];
NormMatGFs = GetNormalizeMatrixColumn(Data.UFiring(ROIt(1):ROIt(2),:));
if Ops.flagstim
    so =  Data.stim_on(ROIt(1):ROIt(2));
end
%% Perform PCA 
[c,PC,l] = pca(NormMatGFs - movmean(NormMatGFs,Ops.fs));
% = s - movmean(s,0.75*Ops.fs);
SI = GetFiringPhaseSorting(NormMatGFs,Ops,'Method','Correlation','Source',PC(:,1));
%%
[PC,Cycles] = GetCycles(PC,Ops.fs/10,Ops.fs);
Cycles = CheckCycles(Cycles);
[GoodCycles,BadCycles] = ExtractCyclesIndices(Cycles,0.1,3,Ops.fs);
CycleLength = cellfun(@(x) length(x),GoodCycles);
MeanFiring = cellfun(@(x) GetResampSig(PC(x,:),2000),GoodCycles,'UniformOutput',false);

%% Raster Plot
fig = figure('Color',Colors().BergGray09,'Position',[0,0,Ops.screensize(3)/3, Ops.screensize(4)/1],'Color',Colors().BergBlack);
cluster_chan = Data.clusters_channels(SI);
wcc = cluster_chan/max(cluster_chan);
C = ((wcc)*Colors().BergBlue + (1-wcc)*[1 1 1]);

ax1 = subplot(10,1,9:10);
Raster = Data.USpiking(ROIt(1):ROIt(2),SI)';
PlotRaster(flipud(Raster),'Colors',flipud(C));
if(Ops.flagstim)
    ax = gca;
    [~,locs] =  findpeaks(abs(diff(Data.stim_on(ROIt(1):ROIt(2)))));
    for n = 1:2:length(locs)-1 
        patch([locs(n) locs(n+1) locs(n+1) locs(n)],[0 0 max(ax.YLim) max(ax.YLim)],[0 0 0],'FaceAlpha',0.3,'FaceColor','white','EdgeColor','white')
    end
end
yticks([1 size(Raster,1)])
yticklabels([1 size(Raster,1)])
ylabel('Nth - Neuron','Color','White','FontSize',12);
xticks(0:5*Ops.fs:size(Raster,2));
xticklabels(0:5:size(Raster,2)/Ops.fs);
xlabel('Time [s]','Color','White','FontSize',12);
box(gca,'off')
set(gca, 'YDir','reverse')
set(gca, 'Color', Colors().BergBlack);
axis([ 0 size(Raster,2) 0 size(Raster,1)])
ax1.YColor = 'White';
ax1.XColor = 'White';
set(ax1,'linewidth',1.5)

yalim = ax1.YLim;

%
ax2 = subplot(10,1,1:8);
set(ax2,'linewidth',1.5)
hold on
ax2.YColor = 'White';
ax2.XColor = 'White';
yticks([min(PC(:,2)) 0 max(PC(:,2))])
yticklabels({'',0,''})
ylabel('PC1','Color','White','FontSize',12);
xticks([min(PC(:,1)) 0 max(PC(:,1))])
xticklabels({'',0,''})
xlabel('PC2','Color','White','FontSize',12);
axis equal
set(gca, 'Color', Colors().BergBlack);
C = [vecnorm(diff(PC(:,1:2))') 0];  % This is the color, vary with x in this case.
colormap(winter);
first = 1;
dispt1 = 0;
for l = [1:Ops.fs/v.FrameRate:length(PC(:,1)) length(PC(:,1))]
    axis([min(PC(:,1)) max(PC(:,1)) min(PC(:,2)) max(PC(:,2))])
    if(l < Ops.fs/2)
        trail = l-1;
    else
        trail = Ops.fs/2;
    end
    plot(ax1,[l l],ax1.YLim ,'Color','White', 'LineWidth', 1.3);
    x = PC(l-trail:l,1)';
    y = PC(l-trail:l,2)';
    z = PC(l-trail:l,3)';%zeros(size(x)); % We don't need a z-coordinate since we are plotting a 2d function
    Col = [C(l-trail:l)/max(C)];
    Sur = surface(ax2,[x;x],[y;y],[z;z],[Col;Col],...
            'FaceColor','none',...
            'EdgeColor','interp','Linewidth',3,'FaceAlpha',0.1);
    if Ops.flagstim
        if(so(l) > 0) 
           t1 = text(min(ax2.XLim) + range(ax2.XLim)/2,max(ax2.YLim) - range(ax2.XLim)/10, 'PPN Stim ON','Color','White','FontSize',18,'FontWeight','bold','HorizontalAlignment','Center');
        end
    end
    drawnow;
    f = getframe(fig);
    writeVideo(v,f);
    %pause(0.01);
    delete(findall(ax1,'Type','Line'));
    if exist('t1')
       delete(t1);
    end
    if exist('Sur')
            delete(Sur);
    end
end

Col1 = ones(length(MeanFiring{1}(:,1)),1);
for w = [1:Ops.fs/v.FrameRate:Ops.fs Ops.fs]
     p1 = cellfun(@(x) patch(ax1,[x(1) x(end) x(end) x(1)],[yalim(1) yalim(1) yalim(2) yalim(2)],Colors().BergYellow,'EdgeColor','white','FaceAlpha',w/(3*Ops.fs)),GoodCycles(1:7));
     s1 = cellfun(@(x) plot(ax2,x(:,1),x(:,2),'Color',[Colors().BergYellow w/Ops.fs],'LineWidth',1.3),MeanFiring(1:7));
     drawnow;
     %pause(0.01);
     f = getframe(fig);
     writeVideo(v,f);
    if w < Ops.fs
        delete(s1);
        delete(p1);
    end
end

for w = [1:Ops.fs/v.FrameRate:Ops.fs*2 Ops.fs*2]
     f = getframe(fig);
     writeVideo(v,f);
end

Col1 = ones(length(MeanFiring{2}(:,1)),1);
for w = [1:Ops.fs/v.FrameRate:Ops.fs Ops.fs]
     p2 = cellfun(@(x) patch(ax1,[x(1) x(end) x(end) x(1)],[yalim(1) yalim(1) yalim(2) yalim(2)],Colors().BergBlue,'EdgeColor','white','FaceAlpha',w/(3*Ops.fs)),GoodCycles(9:end));
     s2 = cellfun(@(x) plot(ax2,x(:,1),x(:,2),'Color',[Colors().BergBlue w/Ops.fs],'LineWidth',1.3),MeanFiring(9:end));
     drawnow;
     %pause(0.01);
     f = getframe(fig);
     writeVideo(v,f);
    if w < Ops.fs
        delete(p2)
        delete(s2);
    end
end

for w = [1:Ops.fs/v.FrameRate:40000 40000]
     f = getframe(fig);
     writeVideo(v,f);
end

close(v)

