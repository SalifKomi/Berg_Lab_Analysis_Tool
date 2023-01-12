%% Run LoadPhyFiles Before Runing this Script.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% ANALYSIS PER CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract Kinematic Cycles
[PCK,CyclesK] = GetKinematicCycles(KinCoord,1000,fs);
CyclesK = CheckCycles(CyclesK);
[GoodCyclesK,BadCyclesK] = ExtractCyclesIndices(CyclesK,0.001,5,fs);
%% Extract Kinematic Cycles
[PC,CyclesPC] = GetCycles(s,fs/8,fs);
CyclesPC = CheckCycles(CyclesPC);
[GoodCyclesPC,BadCyclesPC] = ExtractCyclesIndices(CyclesPC,0.2,1.4,fs);
%%
CycleLength = cellfun(@(x) length(x),GoodCyclesK);

%% Compute Neuron Phase During each Cycles
locMax = [];
for j = 1:size(NormMatGF,2)
    [~,loc] = cellfun(@(x) findpeaks(NormMatGF(x,j),'NPeaks',1,'MinPeakHeight',std(NormMatGF(x,j))),GoodCyclesK,'UniformOutput',false);
    loc = cellfun(@(x) isEmptyToNan(x),loc);
    locMax = [locMax loc'];
end
lin = 1:length(CycleLength);
Phase = cellfun(@(x,y) (x./CycleLength(y)).*2*pi,num2cell(locMax,2),num2cell(lin'),'UniformOutput',false);
%% Group Speed and Average pct = [];
pct = [];
for p = 0:0.25:1
    pct = [pct quantile(CycleLength,p)];
end

SpeedInd = {};
for i = 1:length(pct)-1
    SpeedInd{i} = find(CycleLength > pct(i) & CycleLength <= pct(i+1));
end

Speeds = {};
for S = 1:length(SpeedInd)
    MeanSpeeds = cellfun(@(x) GetResampSig(PC(x,:),2000),GoodCyclesK(SpeedInd{S}),'UniformOutput',false);
    MS = zeros(size(MeanSpeeds{1}));
    for i = 1:length(MeanSpeeds) 
        MS = MS+MeanSpeeds{i};
    end
    Speeds{S} = MS./length(MeanSpeeds);
end
%%
CyclePhaseUn = cell2mat(Phase);
CyclePhaseComplex = GetNormalComplex(CyclePhaseUn);
MeanPhaseUn = nanmean(CyclePhaseUn,1);
MeanPhaseA = angle(MeanPhaseUn);

%% Compute Tangling 
Tanglingoff = cellfun(@(x) sum(ComputeTrajectoryTangling(PC(x,1:3),1,1/fs)), GoodCyclesK); 
Tanglingon = cellfun(@(x) sum(ComputeTrajectoryTangling(PC(x,1:3),1,1/fs)), BadCyclesK); 
Tang = {Tanglingoff,Tanglingon};
Conditions = {'Stim Off','Stim On'};

%% Compute Sorting By Phase
[MeanPhaseA,SortingIndices] = sort(MeanPhaseUn,'ascend');

%% Reorder All Necessary Variable with respect to sorting Indices

CyclePhase = CyclePhaseUn(:,SortingIndices);
MeanPhase = MeanPhaseUn(SortingIndices);
cluster_id = clusters_id(SortingIndices);
cluster_chan = clusters_channels(SortingIndices);

%%
MeanFiring = cellfun(@(x) GetResampSig(PC(x,:),2000),GoodCyclesK,'UniformOutput',false);
MF = zeros(size(MeanFiring{1}));
for i = 1:length(MeanFiring) 
    MF = MF+MeanFiring{i};
end
MF = MF./length(MeanFiring);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Cycle Duration distribution
fig = figure('Color','white','Position',[0,0,screensize(3)/4, screensize(4)]);

lin = num2cell(1:length(SpeedInd));
subplot(2,2,3)
hold on
cellfun(@(x,y) histogram(fs./CycleLength(x),'BinWidth',quantile(fs./CycleLength,0.1)-quantile(fs./CycleLength,0.05),'EdgeColor','white','FaceColor',[Colors().BergBlue/y],'FaceAlpha',0.75),SpeedInd,lin)
xlabel('Cycle Frequency [Hz]');
ylabel('Number of occurances');
title('Distribution of cycle duration');

subplot(2,2,1:2)
hold on 
cellfun(@(x,y) plot3(x(:,1),x(:,2),x(:,3),'LineStyle','-','Color',[Colors().BergBlue/y 0.75],'LineWidth',2.5),Speeds,lin)
view(-70.3,18.6);
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
% legend({'25th-Percentile','50th Percentile','75th Percentile','100th Percentile'});
title('PC Trajectory at various speeds (cycle duration)');

subplot(2,2,4)
col = [];

for j=1:length(SpeedInd)
    col = [col ones(1,length(SpeedInd{j}))*j];
end

hold on
cellfun(@(x,y) scatter(fs./length(GoodCyclesK{x}),sum(mad(PC(GoodCyclesK{x},1:3),0,1)),50,'MarkerFaceColor',Colors().BergBlue/y,'MarkerEdgeColor','none','MarkerFaceAlpha',0.65),num2cell(cell2mat(SpeedInd)),num2cell(col))
xlabel('Cycle Frequency [Hz]');
ylabel('Mean Absolute Difference');
title('Cycle Duration VS Mean Absolute Deviation');
save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['SpeedDistributionAndTrajectories_Kinematic']);

%% Plot Cluster Spatial Distribution
fig = figure('Color','white','Position',[0,0,screensize(3)/4, screensize(4)]);
for q = 1:length(chan_pos)
    patch([chan_pos(q,1)-10 chan_pos(q,1)+10 chan_pos(q,1)+10 chan_pos(q,1)-10],[chan_pos(q,2)-10 chan_pos(q,2)-10 chan_pos(q,2)+10 chan_pos(q,2)+10],[0 0 0],'FaceAlpha',0.2,'FaceColor',Colors().BergBlack)
    hold on
end

for k = 1:size(CyclePhase,2)
    X = [];
    Y = [];
    C = [];
    for l = 1:size(CyclePhase,1) 
        X = [X chan_pos(cluster_chan(k),1)+randsample([-10:0.5:10],1,true)];
        Y = [Y chan_pos(cluster_chan(k),2)+randsample([-10:0.5:10],1,true)];
        C = [C;Colors().BergBlue.*(CyclePhase(l,k)./(2*pi))];
    end        
    scatter(X,Y,40,C,'filled','MarkerFaceAlpha',0.3);
    hold on
    quiver(chan_pos(cluster_chan,1),chan_pos(cluster_chan,2),100*cos(MeanPhase)',100*sin(MeanPhase)',0,'LineWidth',2,'Color',Colors().BergBlue);
end
axis equal 
set(gca, 'YDir','reverse')
%save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['SpatialDistribution']);

%% Plot Phase distribution of sorted units (Bar) 
fig = figure('Color','white','Position',[0,0,screensize(3)/4, screensize(4)]);
lin = [1];% 1:length(SpeedInd);
cellfun(@(x) PlotBarandScatter(num2cell(CyclePhase(x,:),1),num2cell(1:size(CyclePhase(x,:),2))),SpeedInd(lin))
save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['PhaseDistributionBar'])
%% Plot Phase distribution of sorted units (Polar)
fig = figure('Color','white','Position',[0,0,screensize(3)/4, screensize(4)]);
for i = 1:size(CyclePhase,2)
cellfun(@(x,y) polarscatter(CyclePhase(x,i),i*ones(length(CyclePhase(x,i)),1),50,Colors().BergBlue/y,'filled','MarkerFaceAlpha',0.5),SpeedInd(lin),num2cell(lin))
hold on
end
set(gca,'Color',Colors().BergGray09);
save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['PhaseDistributionPolar'])

%% Plot Cycles in PC spaces

fig = figure('Color','white','Position',[0,0,screensize(3)/4, screensize(4)]);
hold on 
der = cellfun(@(x) max(diff(PC(x(1:100:end),1))),GoodCyclesK);
der = der./max(der);
lin_ind = 1:length(der);
cellfun(@(x,y) plot3(PC(x(1:100:end),1),PC(x(1:100:end),2),PC(x(1:100:end),3),'LineStyle','-','Color',[Colors().BergGray09 0.3],'LineWidth',1),GoodCyclesK,num2cell(lin_ind));
cellfun(@(x) scatter3(PC(x(1),1),PC(x(1),2),PC(x(1),3),20,'MarkerFaceColor',Colors().BergBlue,'MarkerEdgeColor','none'),GoodCyclesK);
cellfun(@(x) scatter3(PC(x(end),1),PC(x(end),2),PC(x(end),3),20,'MarkerFaceColor',Colors().BergYellow,'MarkerEdgeColor','none'),GoodCyclesK);
%plot3(MF(:,1),MF(:,2),MF(:,3),'LineStyle','-','Color',[Colors().BergBlue 1],'LineWidth',5)
% legend({'PPN Stim OFF','PPN Stim ON'});
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
axis equal
axis square
view(133.5,-23.3);
%view(-35.0,27);
%save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['CyclesInPCSpace'])

%%
fig = figure('Color','white','Position',[0,0,screensize(3)/4, screensize(4)]);
hold on 
plot3(PC(1:100:end,1),PC(1:100:end,2),PC(1:100:end,3),'LineStyle','--','Color',[Colors().BergGray09 0.3],'LineWidth',1);
%cellfun(@(x) plot3(PC(x(1:100:end),1),PC(x(1:100:end),2),PC(x(1:100:end),3),'LineStyle','--','Color',Colors().BergOrange,'LineWidth',1),BadCycles);
%legend({'PPN Stim OFF','PPN Stim ON'});
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
axis equal
axis square
view(135,52);
%save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['CyclesInPCSpace_Raw'])

%% Make Comet Animation of PC Space

traillength = 100000;
figure 
ax1 = axes;
% axis equal
ylabel('PC2');
% axis square
legend({'PPN Stim OFF'});

for i = 1:1000:length(PC)
    cla
    axis([min(PC(:,1)) max(PC(:,1)) min(PC(:,2)) max(PC(:,2)) min(PC(:,3)) max(PC(:,3))]); 
    if i < traillength
        trail = i-1;
    else%% Compute Tangling 
        trail = traillength;
    end
    plot3(PC(i-trail:i,1),PC(i-trail:i,2),PC(i-trail:i,3),'LineStyle','-','Color',[0 0 0 0.5],'LineWidth',1);
    hold on 
    scatter3(ax1,PC(i,1),PC(i,2),PC(i,3),30,'MarkerFaceColor',Colors().BergBlue);
    drawnow;
end


%% Plot Whole Trial Raster
fig = figure('Color','white','Position',[0,0,screensize(3)/1, screensize(4)/5]);
% Smooth Firing Rate
% ax1 = subplot(2,1,1);
Firing = GF(:,SortingIndices); 
Firing = (Firing -min(Firing,[],2))./(max(Firing,[],2) -min(Firing,[],2));
[X,Y] = meshgrid(1:size(Firing,1),1:size(Firing,2));
[Xq,Yq] = meshgrid(1:1:size(Firing,1),1:size(Firing,2));
Firing = interp2(X,Y,Firing',Xq,Yq);
imagesc(exp(Firing'))
colormap(viridis);
yticks(1:1:size(Firing,2))
yticklabels(1:1:size(Firing,2))
ylabel('Nth-Neuron');
xticks(0:fs:size(Firing,1));
xticklabels(0:1:size(Firing,1)/fs);
xlabel('Time [s]');
box(gca,'off')
%xlim([300000 1000000 ])
save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['FiringRatesSorted']);

%%
fig = figure('Color','white','Position',[0,0,screensize(3)/1, screensize(4)/5]);
% Raster    
Raster = ST(:,SortingIndices)';
% ax2 = subplot(2,1,2);
PlotRaster(Raster);
% set(gca,'Color',Colors().BergGray09)
yticks(1:1:size(Raster,1))
yticklabels(1:1:size(Raster,1))
ylabel('Nth-Neuron');
xticks(0:fs:size(Raster,2));
xticklabels(0:1:size(Raster,2)/fs);
xlabel('Time [s]');
box(gca,'off')
set(gca, 'YDir','reverse')
axis([ 0 size(Raster,2) 0 size(Raster,1)])
yalim = ylim;
%xlim([300000 1000000 ])
cellfun(@(x,y) patch([GoodCyclesK{x}(1) GoodCyclesK{x}(end) GoodCyclesK{x}(end) GoodCyclesK{x}(1)],[yalim(1) yalim(1) yalim(2) yalim(2)],Colors().BergBlue/y,'EdgeColor','white','FaceAlpha',0.4),num2cell(cell2mat(SpeedInd)),num2cell(col));
%save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['RasterSorted']);


