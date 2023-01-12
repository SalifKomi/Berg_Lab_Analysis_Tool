function PlotBarandScatter(Data,Conditions) 

%%% Data needs to be a cell array with the data from the different group to
%%% display. 
% figure
    width = 0.5;
    for jj = 1:length(Data)
        tmean = nanmean(Data{jj});
        Std = std(Data{jj});
        patch([jj-width/2 jj+width/2 jj+width/2 jj-width/2],[0 0 tmean tmean],Colors().BergBlue,'FaceAlpha',0.6/jj); 
        hold on
        scatter(ones(length(Data{jj}),1)*jj,Data{jj},10,'MarkerEdgeColor','none','MarkerFaceColor',Colors().BergBlue*(1/jj),'LineWidth',1.5)
    end
    xlim([0 length(Conditions)+1]);
    labels = Conditions;
    xticks([1:length(labels)]);
    xticklabels(labels);
    xtickangle(30);
    axis square

end
