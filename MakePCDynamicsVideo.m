clearvars -except Data Ops Folder
%% Video Parameters and variables
mkdir([Ops.DataFolder filesep 'Videos']);
v = VideoWriter([Ops.DataFolder filesep 'Videos' filesep 'PCDynamics']);
v.FrameRate = Data.Video.FrameRate;
v.Quality = 100;
open(v);

%% ROI Variables 
pctt = double(length(Data.UFiring)/100); % Percent of the recording duration
pcts = double(ceil(range(Data.chan_pos(:,2))/100)); % spatial percentage
ROIt = pctt.*[82.08 87.5];

drec = Data.rec_on(1:ROIt(1));
drec = drec(drec > 0);
FirstFrame = sum(drec) + 1;
recsig = Data.rec_on(ROIt(1):ROIt(2));

%% Plot Spatial PC
NormMatGFs = GetNormalizeMatrixColumn(Data.UFiring(ROIt(1):ROIt(2),:));
if Ops.flagstim
    so =  Data.stim_on(ROIt(1):ROIt(2));
end
%% Perform PCA 
[c,PC,l] = pca(NormMatGFs - movmean(NormMatGFs,Ops.fs));
SI = GetFiringPhaseSorting(NormMatGFs,Ops,'Method','Coherence','Source',PC(:,1));
%% Extract Cycles 
[PC,Cycles] = GetCycles(PC,Ops.fs/10,Ops.fs);
Cycles = CheckCycles(Cycles);
[GoodCycles,BadCycles] = ExtractCyclesIndices(Cycles,0.1,3,Ops.fs);
CycleLength = cellfun(@(x) length(x),GoodCycles);
MeanFiring = cellfun(@(x) GetResampSig(PC(x,:),2000),GoodCycles,'UniformOutput',false);
%% Start Plotting
% fig = figure('Color',Colors().BergGray09,'Position',[0,0,Ops.screensize(3)/2, Ops.screensize(4)/1],'Color', 'none');%[0 0 0]);
cluster_chan = Data.clusters_channels(SI);
wcc = cluster_chan/max(cluster_chan);
C = ((1-wcc)*Colors().BergYellow + (wcc)*Colors().BergBlue);
% C = ((wcc)*Colors().BergBlue + (1-wcc)*[1 1 1]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Video Axes  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fig,ha] = LoadBackgroundFigure();

[x1,y1,w1,h1] = ChangeCoordinates(0.377,0.05,0.595,0.6);
ax1=axes('position',[x1,y1,w1,h1]);

[x4,y4,w4,h4] = ChangeCoordinates(0.38,0.7,0.4,0.225);
ax3 = axes('position',[x4,y4,w4,h4]);

[x2,y2,w2,h2] = ChangeCoordinates(0.8,0.7,0.2,0.225);
ax2=axes('position',[x2,y2,w2,h2]);


%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Raster Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(ax3)
Raster = Data.USpiking(ROIt(1):ROIt(2),SI)';
PlotRaster(flipud(Raster),'Colors',flipud(C));
yticks([1 size(Raster,1)])
yticklabels([1 size(Raster,1)])
ylabel('Nth - Neuron','Color','White','FontSize',12);
xticks(0:5*Ops.fs:size(Raster,2));
xticklabels(0:5:size(Raster,2)/Ops.fs);
xlabel('Time [s]','Color','White','FontSize',12);
box(gca,'off')
set(gca, 'YDir','reverse')
set(gca, 'Color', 'none');%[0 0 0]);
axis([ 0 size(Raster,2) 0 size(Raster,1)])
ax3.YColor = 'White';
ax3.XColor = 'White';
set(ax3,'linewidth',1.5)
yalim = ax3.YLim;

%
axes(ax2)
set(ax2,'linewidth',1.5)
hold on
ax2.YColor = 'White';
ax2.XColor = 'White';
yticks([min(PC(:,2)) 0 max(PC(:,2))]*1.1)
yticklabels({'',0,''})
ylabel('PC1','Color','White','FontSize',12);
xticks([min(PC(:,1)) 0 max(PC(:,1))])
xticklabels({'',0,''})
xlabel('PC2','Color','White','FontSize',12);
axis equal
set(gca, 'Color', 'none'); % [0 0 0]);
C1 = [vecnorm(diff(PC(:,1:2))') 0];  % This is the color, vary with x in this case.
colormap(winter);


% axes(ax3)
% set(ax3,'linewidth',1.5)
% hold on
% ax3.YColor = 'White';
% ax3.XColor = 'White';
% yticks([min(PC(:,2)) 0 max(PC(:,2))])
% yticklabels({'',0,''})
% ylabel('PC1','Color','White','FontSize',12);
% xticks([min(PC(:,1)) 0 max(PC(:,1))])
% xticklabels({'',0,''})
% xlabel('PC2','Color','White','FontSize',12);
% axis equal
% set(gca, 'Color', Colors().BergBlack);
% C2 = [vecnorm(diff(PC(:,2:3))') 0];  % This is the color, vary with x in this case.
% colormap(winter);

%%%%%%%%%%%%%%%%%%%%%%%% Update Plots and Save %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Frame = 0;
SaveInd = find(recsig);
for l = SaveInd
    axis(ax2,[min(PC(:,1)) max(PC(:,1)) min(PC(:,2)) max(PC(:,2))]*1.1)
    if(l < Ops.fs/2)
        trail = l-1;
    else
        trail = Ops.fs/2;
    end
    if(l == 1 || (recsig(l) > 0))
        plot(ax3,[l l],ax3.YLim ,'Color','White', 'LineWidth', 1.3);
        x = PC(l-trail:l,1)';
        y = PC(l-trail:l,2)';
        z = PC(l-trail:l,3)';
        w = zeros(size(x)); % We don't need a z-coordinate since we are plotting a 2d function
        Col1 = [C1(l-trail:l)/max(C1)];
        Sur1 = surface(ax2,[x;x],[y;y],[w;w],[Col1;Col1],...
                'FaceColor','none',...
                'EdgeColor','interp','Linewidth',3,'FaceAlpha',0.1);
        frame = read(Data.Video,FirstFrame+Frame);
        image(ax1,frame);
        ax1.Visible = 'off';
        drawnow;
        f = getframe(fig);
        writeVideo(v,f); 
        if(l < SaveInd(end))
            if exist('t1')
               delete(t1);
            end
            if exist('Sur1')
               delete(Sur1);
            end
            delete(findall(ax3,'Type','Line'));
        end
        Frame = Frame + 1;
    end
end
close(v)

