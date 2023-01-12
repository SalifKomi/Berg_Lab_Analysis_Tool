%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% ANALYSIS PER STIM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
[PC,~] = GetCycles(s,fs/8,fs);
%% Split in ON/OFF Stim periods 
onInd = find(Stim_on(1:length(GF)) == 1);
offInd = find(Stim_on(1:length(GF)) == 0); 
onInd = SplitVec(onInd,'consecutive');
offInd = SplitVec(offInd,'consecutive');


%%
[val, lags] = cellfun(@(x) xcorr(GF(x,:)),onInd)


%%
MeanFiringOn = cellfun(@(x) GetResampSig(PC(x,:),2000),onInd,'UniformOutput',false);
MFOn = zeros(size(MeanFiringOn{1}));
for i = 1:length(MeanFiringOn) 
    MFOn = MFOn +MeanFiringOn{i};
end
MFOn = MFOn./length(MeanFiringOn);

MeanFiringOff= cellfun(@(x) GetResampSig(PC(x,:),2000),offInd,'UniformOutput',false);
MFOff = zeros(size(MeanFiringOff{1}));
for i = 1:length(MeanFiringOff) 
    MFOff = MFOff +MeanFiringOff{i};
end
MFOff = MFOff./length(MeanFiringOff);

%% Split Data for jPCA
Data = struct();
for i = 1:length(MeanFiringOff)
    Data(i).A = MeanFiringOff{i};
end
j = length(Data);
for i =  1:length(MeanFiringOn)
        Data(j + i).A = MeanFiringOn{i};
end
%% Perform jPCA 
[s,smary] = jPCA(Data,[],[]);
phaseSpace(s,smary);
%% Compute Correlation Coeeficient with Stim
CorrMat = ComputeStimFiringCorrelation(Sum,Stim_on);
[CorrMat,CorrLoc] = sort(CorrMat,'descend'); %% Inverted CorrMat to get positive correlation since activity is anticorrelated with stim
HighCorr = (CorrMat > std(CorrMat));
LowCorr = (CorrMat < std(CorrMat));
%% Compute Mean Delta Activity
SumOn = cell2mat(cellfun(@(x) mean(GF(x,:),1),onInd,'UniformOutput',false));
SumOff = cell2mat(cellfun(@(x) mean(GF(x,:),1),offInd,'UniformOutput',false));
MeanOn = mean(SumOn,1);
MeanOff = mean(SumOff,1);
%%  Which Units Display the biggest relative change in Firing Frequency Between ON and OFF
RelChange = (MeanOff-MeanOn);%./MeanOff;
[RelChange,ChangeInd] = sort(RelChange,'descend');
KeepInd = ChangeInd(RelChange > std(RelChange));
NChange = length(KeepInd); 
%% Compute 

%% Split PCA 
GFOff = GF(cell2mat(offInd),:);
[coff,soff,loff] = pca(GFOff);
GFOn = GF(cell2mat(onInd),:);
[con,son,lon] = pca(GFOn);
%% Compute Tangling of trajectory for all permutation of N/2 
Tanglingoff = cellfun(@(x) sum(ComputeTrajectoryTangling(PC(x,1:3),1,1/fs))./length(PC(x,1:3)), offInd); 
Tanglingon = cellfun(@(x) sum(ComputeTrajectoryTangling(PC(x,1:3),1,1/fs))./length(PC(x,1:3)), onInd); 
Tang = {Tanglingoff,Tanglingon};
Conditions = {'Stim Off','Stim On'};
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot Firing Rates 
fig = figure('Color','white','Position',[0,0,screensize(3), screensize(4)]);
offset = [0:size(Sum,1)-1];
plot(bsxfun(@plus ,Sum , offset),'LineWidth',1.2,'Color',[0 0 0 0.3]);
hold on
yalim = ylim;
cellfun(@(x,y) patch([x(1) x(end) x(end) x(1)],[yalim(1) yalim(1) yalim(2) yalim(2)],Colors().BergBlue,'EdgeColor','white','FaceAlpha',0.4),onInd);
xlim([10000000 25000000])

%%
figure
plot(son(1:100:end,1),son(1:100:end,2),'LineStyle','--','Color',Colors().BergBlack,'LineWidth',1);
legend({'PPN Stim ON'});
xlabel('PC1');
ylabel('PC2');
axis square
axis equal

%%
figure 
plot(soff(1:100:end,1),soff(1:100:end,2),'LineStyle','-','Color',[Colors().BergBlue 0.5],'LineWidth',1);
legend({'PPN Stim OFF'});
xlabel('PC1');
ylabel('PC2');
axis square
axis equal

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
    axis([min(Y(:,1)) max(Y(:,1)) min(Y(:,2)) max(Y(:,2))]); 
    if i < traillength
        trail = i-1;
    else%% Compute Tangling 
        trail = traillength;
    end
    plot(Y(i-trail:i,1),Y(i-trail:i,2),'LineStyle','-','Color',[0 0 0 0.5],'LineWidth',1);
    hold on 
    scatter(ax1,Y(i,1),Y(i,2),30,'MarkerFaceColor',Colors().BergRed);
    drawnow;
end

%% Projection on 2-First PCs

figure 
hold on 
cellfun(@(x) plot(PC(x(1:100:end),1),PC(x(1:100:end),2),'LineStyle','-','Color',[0 0 0 0.5],'LineWidth',1),{1:length(GF)});
% cellfun(@(x) plot(s(x(1:100:end),1),s(x(1:100:end),2),'LineStyle','--','Color',Colors().BergRed,'LineWidth',1),onInd);
legend({'PPN Stim OFF','PPN Stim ON'});
xlabel('PC1');
ylabel('PC2');
axis square
axis equal

%% Projection on 2-second PCs
figure
hold on
cellfun(@(x) plot(PC(x(1:100:end),3),PC(x(1:100:end),2),'LineStyle','-','Color',[0 0 0 0.5],'LineWidth',1),offInd);
cellfun(@(x) plot(PC(x(1:100:end),3),PC(x(1:100:end),2),'LineStyle','--','Color',Colors().BergRed,'LineWidth',1),onInd);
legend(['PPN Stim OFF','PPN Stim ON']);
xlabel('PC3');
ylabel('PC2');
axis square
axis equal

%%
fig = figure('Color','white','Position',[0,0,screensize(3), screensize(4)]);

hold on 
cellfun(@(x) plot3(PC(x(1:100:end),1),PC(x(1:100:end),2),PC(x(1:100:end),3),'LineStyle','-','Color',[Colors().BergBlue 1],'LineWidth',2),onInd);
cellfun(@(x) plot3(PC(x(1:100:end),1),PC(x(1:100:end),2),PC(x(1:100:end),3),'LineStyle','-','Color',[Colors().BergGray09 0.12],'LineWidth',2),offInd);
% 
% plot3(MFOn(:,1),MFOn(:,2),MFOn(:,3),'LineStyle','-','Color',[Colors().BergBlue 1],'LineWidth',5)
% plot3(MFOff(:,1),MFOff(:,2),MFOff(:,3),'LineStyle','-','Color',[Colors().BergBlack 1],'LineWidth',5)

xlabel('PC1');
ylabel('PC2');
zlabel('PC3');

axis equal
axis square
view(-70.3,18.6);
save2pdf(fig,['Figures'],['StimOnStimOffTrajectories']);

% linkaxes

%%



%% Plot Whole Trial Raster
fig = figure('Color','white','Position',[0,0,screensize(3)/1.5, screensize(4)/4]);
% Smooth Firing Rate
% ax1 = subplot(2,1,1);
% Firing = GF(:,SortingIndices)'; 
% Firing = (Firing -min(Firing,[],2))./(max(Firing,[],2) -min(Firing,[],2));
% [X,Y] = meshgrid(1:size(Firing,1),1:size(Firing,2));
% [Xq,Yq] = meshgrid(1:1:size(Firing,1),1:size(Firing,2));
% Firing = interp2(X,Y,Firing',Xq,Yq);
% imagesc(exp(Firing'))
% colormap(viridis);

% yticks(1:1:size(Firing,2))
% yticklabels(1:1:size(Firing,2))
% ylabel('Nth-Neuron');
% xticks(0:20000:size(Firing,1));
% xticklabels(0:1:size(Firing,1)/20000);
% xlabel('Time [s]');
% box(ax1,'off')

% Raster    
Raster = ST(:,:)';
% ax2 = subplot(2,1,2);
PlotRaster(Raster);
% set(gca,'Color',Colors().BergGray09)
yticks(1:1:size(Raster,1))
yticklabels(1:1:size(Raster,1))
ylabel('Nth-Neuron');
xticks(0:20000:size(Raster,2));
xticklabels(0:1:size(Raster,2)/20000);
xlabel('Time [s]');
box(gca,'off')
set(gca, 'YDir','reverse')

linkaxes
axis([ 0 size(Raster,2) 0 size(Raster,1)])

% plot(length(ClusterFiring).*diff(PC(:,2)-PC(:,1))./max(diff(PC(:,2)-PC(:,1))),'LineStyle','--','Color',Colors().BergBlue);
% scatter(Cycles.End,length(ClusterFiring).*ones(length(Cycles.End),1))
% scatter(Cycles.Start,length(ClusterFiring).*ones(length(Cycles.Start),1))
% plot(length(ClusterFiring).*Stim_on,'LineStyle','--','Color','blue');
yalim = ylim;
% xlim([13944100 14100400])
cellfun(@(x,y) patch([x(1) x(end) x(end) x(1)],[yalim(1) yalim(1) yalim(2) yalim(2)],Colors().BergBlue,'EdgeColor','white','FaceAlpha',0.4),onInd);

% save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['RasterAndFiringRates']);