function PlotRaster(SpikeTrain,varargin)
  C = [];
  M = 5 ;
  P = 0:size(SpikeTrain,1)-1;
  for v = 1:2:length(varargin)
      switch varargin{v}
          case 'Colors'
              C = varargin{v+1};
          case 'Pos'
              P = varargin{v+1};
          case 'MarkerSize'
              M = varargin{v+1};
      end     
  end  
  for i = 1:size(SpikeTrain,1)
      indices = find(SpikeTrain(i,:));
      if isempty(C)
        scatter(indices,SpikeTrain(i,indices) + P(i),M,'MarkerFaceColor',Colors().BergGray09,'MarkerFaceAlpha',0.3,'MarkerEdgeColor','none');
      else
        scatter(indices,SpikeTrain(i,indices) + P(i),M,'MarkerFaceColor',C(i,:),'MarkerFaceAlpha',0.3,'MarkerEdgeColor','none');
      end
      hold on
  end
end
