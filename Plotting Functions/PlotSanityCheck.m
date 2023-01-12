screensize = get(groot,'ScreenSize');
NNeurons = size(ST,2); 
fig = figure('Color','white','Position',[0,0,screensize(3)/4, screensize(4)]);
j = 1;
for i = 29:35 
    subplot(7,1,j)
    [c,lags] = xcorr(ST(:,i),2000);
    ind = find(lags == 0);
    lags(ind) = [];
    c(ind) = [];
    stem(lags,c)
    j = j+1;
end 
save2pdf(fig,[FileContent(1).folder filesep 'Figures'],['AutoCorrelogramsUnits29-35']);
