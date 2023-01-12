function fig = PlotOrderedRaster(Data,Ops,varargin)
%% Set Parameters and Data to plot
Mode = 'Units';
Save = 0;
for v = 1:2:length(varargin)
  switch varargin{v}
      case 'Mode'
          Mode = varargin{v+1};
      case 'Save'
          Save = varargin{v+1};
  end     
end  
[cc,SI] = sort(Data.clusters_channels);
cc = cc+1;
Raster = Data.USpiking(:,SI)';
wcc = cc/max(cc);
C = ((1-wcc)*Colors().BergYellow + (wcc)*Colors().BergBlue);
%% Generate Figure
fig = figure('Color',Colors().BergGray09,'Position',[0,0,Ops.screensize(3)/1, Ops.screensize(4)/1],'Color',Colors().BergGray09);
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
%% Raster Plot
PlotRaster(flipud(Raster),'Colors',flipud(C),'Pos',Pos,'MarkerSize',3);
if(Ops.flagstim)
    ax = gca;
    [~,locs] =  findpeaks(abs(diff(Data.stim_on)));
    for n = 1:2:length(locs)-1 
        patch([locs(n) locs(n+1) locs(n+1) locs(n)],[0 0 max(ax.YLim) max(ax.YLim)],[0 0 0],'FaceAlpha',0.3,'FaceColor','white','EdgeColor','white')
    end
end
yticks(Ytick);
yticklabels(Ytick);
ylabel('Nth-Neuron');
xticks(0:Ops.fs:size(Raster,2));
xticklabels(0:1:size(Raster,2)/Ops.fs);
xlabel('Time [s]');
box(gca,'off')
set(gca, 'YDir','reverse')
set(gca, 'Color', Colors().BergGray09);
axis([ 0 size(Raster,2) 0 size(Raster,1)])

if(setax)
    set(gca,'YLim',[0 max(Data.chan_pos(:,2))])
else
    set(gca, 'YDir','reverse')
    set(gca,'YLim',1.05*gca().YLim)
end   
if(Save)
    save2pdf(fig,[Ops.DataFolder filesep 'Figures'],['Raster_' Mode],'-dpng');
end
end

