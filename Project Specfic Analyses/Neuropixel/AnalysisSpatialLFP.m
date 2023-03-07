%% Spatial Analysis
clearvars -except Data Ops Folder
close all 
clc
%% Plot Spatial PC
Data.CFiring(1,:) = [];
pctt = double(length(Data.CFiring)/100); % Percent of the recording duration
pcts = double(ceil(range(Data.chan_pos(:,2))/100)); % spatial percentage
Nc = 3; 

TOI = [98.5 105];
TOI2 = [0 0];
ROIt = pctt.*100*TOI/(size(Data.CFiring,1)/Ops.fs) +[1 0];%;
ROIt2 = pctt.*100*TOI2/(size(Data.CFiring,1)/Ops.fs) +[1 0];%;

ROIt = round(ROIt);
ROIt2 = round(ROIt2);

ROIs = min(Data.chan_pos(:,2)) +pcts.*[0 100];
ROIs2 = min(Data.chan_pos(:,2)) +pcts.*[0 100];

% Spatial Sorting 
CI1 = find((Data.chan_pos(:,2)>= ROIs(1)) & (Data.chan_pos(:,2) <= ROIs(2)));
SInd1 = ismember(Data.CChannels,CI1);
%SInd1 = Data.UoI & SInd1';

CI2 = find((Data.chan_pos(:,2)>= ROIs2(1)) & (Data.chan_pos(:,2) <= ROIs2(2)));
SInd2 = ismember(Data.CChannels,CI2);
%SInd2 = Data.UoI & SInd2';

if(~isempty(find(SInd2)) && ~isempty(find(SInd1)) )
    MatGFs = Data.CFiring([ROIt(1):ROIt(2)],:);
    MGF1 = Data.CFiring(ROIt(1):ROIt(2),:);    
    MGF2 = Data.CFiring(ROIt2(1):ROIt2(2),:);    
%     
    N = rmmissing(MatGFs-movmean(MatGFs,Ops.fs/2),2);
    N1 = rmmissing(MGF1-movmean(MGF1,Ops.fs/2),2);
    N2 = rmmissing(MGF2-movmean(MGF2,Ops.fs/2),2); 
    
    NoI = N;
    [c,s,l] = pca(NoI);
    Mdl = rica(s(:,1:Nc),Nc);
    cica = c;
    %[SI,Ang] = GetFiringPhaseSorting(N,Ops,'Method','Correlation','Source',s(:,1));     
           
%% Plot Subspace
    fig = figure('Color','white','Position',[0,0,Ops.screensize(3)/3, Ops.screensize(4)]);
    
    Ntp1 = N1;
    Ntp1(:,~SInd1) = 0;
    Ntp2 = N2;
    Ntp2(:,~SInd2) = 0;
    
    subplot(1,2,1)
    NNtp1ICA = (Ntp1*cica(:,1:Nc))*Mdl.TransformWeights';
    plot3(NNtp1ICA(:,1),NNtp1ICA(:,2),NNtp1ICA(:,3),'Color',Colors().BergGray09,'LineWidth',2 )
    hold on

    NNtp2ICA = (Ntp2*cica(:,1:Nc))*Mdl.TransformWeights';
    plot3(NNtp2ICA(:,1),NNtp2ICA(:,2),NNtp2ICA(:,3),'Color',Colors().BergOrange,'LineWidth',2 )
    axis square
    axis equal
    view(180,0);
    
    subplot(1,2,2)
    NNtp1 = Ntp1*c;
    plot3(NNtp1(:,1),NNtp1(:,2),NNtp1(:,3),'Color',Colors().BergGray09,'LineWidth',2 )
    hold on
    Ntp2 = N2;
    Ntp2(:,~SInd2) = 0;
    NNtp2 = Ntp2*c;
    plot3(NNtp2(:,1),NNtp2(:,2),NNtp2(:,3),'Color',Colors().BergOrange,'LineWidth',2 )
    axis square
    axis equal
    view(180,0);
else 
    disp('SInd is empty');
end

%%
%% Plot Cluster Spatial Distribution
fig = figure('Color','white','Position',[0,0,Ops.screensize(3)/4, Ops.screensize(4)]);
cluster_chan = Data.CChannels+1;
Components = 'PCA';

switch Components
    case 'ICA'
        wcc = cica(:,1:Nc)*Mdl.TransformWeights'./max(cica(:,1:Nc)*Mdl.TransformWeights',[],1);
        PC = NoI*cica(:,1:Nc)*Mdl.TransformWeights';
    case 'PCA'
        wcc = c./max(c,[],1);
        PC = NoI*c;
end

wcc(wcc<=0) = 0.001;
wcc = abs(wcc);% + 0.0000001;

col = {Colors().BergBlue, Colors().BergOrange, Colors().BergYellow};
for comp = 1:Nc
    subplot(10,Nc,(1:Nc:(9*Nc-1))+(comp-1))
    for q = 1:length(Data.chan_pos)
        patch([Data.chan_pos(q,1)-10 Data.chan_pos(q,1)+10 Data.chan_pos(q,1)+10 Data.chan_pos(q,1)-10],[Data.chan_pos(q,2)-10 Data.chan_pos(q,2)-10 Data.chan_pos(q,2)+10 Data.chan_pos(q,2)+10],[0 0 0],'FaceAlpha',0.2,'FaceColor',Colors().BergBlack)
        hold on
    end
    X =  Data.chan_pos(cluster_chan,1)+randsample([-10:0.5:10],length(cluster_chan),true)';
    Y =  Data.chan_pos(cluster_chan,2)+randsample([-10:0.5:10],length(cluster_chan),true)';
    S =  250*wcc(:,comp);    
    scatter(X,Y,S,col{mod(comp-1,3)+1},'filled','MarkerFaceAlpha',0.75);
    hold on
    axis equal 
end

subplot(10,Nc,9*Nc+1:9*Nc+comp)
for ii = 1:Nc
    plot(PC(:,ii),'Color',col{mod(ii-1,3)+1},'LineWidth',1.5);
    hold on
end
plot(-PC(:,1)-PC(:,2),'Color',Colors().BergGray05,'LineStyle','--','LineWidth',1.5);
box off
%set(gca, 'YDir','reverse')
%save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['SpatialDistribution']);

%%
hand = [];
hand2 = [];
cluster_chan = Data.CChannels+1;
col = {Colors().BergBlue, Colors().BergOrange, Colors().BergYellow};   

%%
[~,cind] = sort(Data.CChannels);
ColorsLin = linspace(0,1,length(Data.chan_pos));
C = ColorsLin(cind);
ncluster= 10;
rlimit = 0;
Sig = [];
fig = figure('Color','white','Position',[0,Ops.screensize(4),Ops.screensize(3), Ops.screensize(4)]);
for clust = 1:ncluster
    ix = round(max((clust-1)*(length(Data.chan_pos)/ncluster)+1,1):clust*(length(Data.chan_pos)/ncluster));
    h = subplot(10,ncluster,(1:ncluster:(7*ncluster-1))+(clust-1));
    for q = 1:length(Data.chan_pos)
        patch([Data.chan_pos(q,1)-10 Data.chan_pos(q,1)+10 Data.chan_pos(q,1)+10 Data.chan_pos(q,1)-10],[Data.chan_pos(q,2)-10 Data.chan_pos(q,2)-10 Data.chan_pos(q,2)+10 Data.chan_pos(q,2)+10],[0 0 0],'FaceAlpha',0.2,'FaceColor',Colors().BergBlack)
        hold on
    end
    IOI = zeros(size(cluster_chan,1),1);
    IOI(ismember(cluster_chan,ix)) = 1;
    IOI = logical(IOI);
    X =  Data.chan_pos(cluster_chan,1)+randsample([-10:0.5:10],length(cluster_chan),true)';
    Y =  Data.chan_pos(cluster_chan,2)+randsample([-10:0.5:10],length(cluster_chan),true)';
    S =  75*(IOI)+0.00001;   
    scatter(X,Y,S,C,'filled','MarkerFaceAlpha',0.5); %col{mod(clust-1,3)+1}
    colormap('cool')
    caxis([0 1]);
    hold on
    axis equal 
    if(clust > 1)
        axis off 
    else
        ax1 = gca;                   % gca = get current axis
        ax1.XAxis.Visible = 'off';   % remove y-axis    
    end 
    h1 =  subplot(10,ncluster,[8*ncluster+clust 9*ncluster+clust]);
    sig = sum(NoI(:,IOI),2);
    
    
    Phases = cell2mat(PhasePerCycle(s,sig,Ops));
    polarscatter(Phases(:),ones(size(Phases(:))),50,mean(ColorsLin(IOI)).*ones(size(Phases(:))),'filled','MarkerFaceAlpha',0.5); %[col{mod(clust-1,3)+1}]  
    hold on
    %polarscatter(Ang(IOI),ones(size(find(IOI))),50,ColorsLin(IOI),'filled','MarkerFaceAlpha',0.5); %[col{mod(clust-1,3)+1}]  
    colormap('cool')
    caxis([0 1]);
    rlimit = max(rlimit,get(gca,'rlim'));
     Sig = [Sig sig];
end       

ch = get(gcf,'Children');
for ii = 1:length(ch)
    if(isa(ch(ii),'PolarAxes'))
        set(ch(ii),'rlim',rlimit);
    end
end
%save2pdf(fig,[Ops.DataFolder filesep 'Figures'],['SpatialDistributionPhasesSpatialCycles'],'-dpdf');
fig = figure('Color','white','Position',[0,0,Ops.screensize(3), Ops.screensize(4)]);
plot(Sig + repmat([1:size(Sig,2)]*max(max(Sig)),size(Sig,1),1))

%%
function Phase = PhasePerCycle(Source,Signal,Ops)
    [~,Cycles] = GetCycles(Source,Ops.fs/10,Ops.fs);%GetNormalizeMatrixColumn(Data.PCs)
    Cycles = CheckCycles(Cycles);
    [GoodCycles,~] = ExtractCyclesIndices(Cycles,0.2,2,Ops.fs);
    CycleLength = cellfun(@(x) length(x),GoodCycles);

    locMax = [];
    for j = 1:size(Signal,2)
        [~,loc] = cellfun(@(x) GetFiringPhaseSorting(repmat(Signal(x,j),10,1),Ops,'Method','Coherence','Source',repmat(Source(x,1),10,1)),GoodCycles,'UniformOutput',false);      
        %[~,loc] = cellfun(@(x) findpeaks(Signal(x,j),'NPeaks',1,'MinPeakHeight',std(Signal(x,j))),GoodCycles,'UniformOutput',false);
        loc = cellfun(@(x) isEmptyToNan(x),loc);
        locMax = [locMax loc'];
    end
    lin = 1:length(CycleLength);
    Phase = cellfun(@(x) x, num2cell(locMax,2),'UniformOutput',false);
    %Phase = cellfun(@(x,y) (x./CycleLength(y)).*2*pi,num2cell(locMax,2),num2cell(lin'),'UniformOutput',false);
end


