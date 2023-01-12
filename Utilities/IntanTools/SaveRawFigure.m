screensize = get(groot,'ScreenSize');
fig = figure('Color','white','Position',[0,0,screensize(3), screensize(4)]);
offset = [0:size(IntanData.amplifier_data,1)-1];
plot(bsxfun(@plus ,8*IntanData.amplifier_data(:,1:100:end)'/max(max(IntanData.amplifier_data)), offset),'LineWidth',1.2,'Color',[0 0 0 0.3]);
save2pdf(fig,[ erase(filepath,'.rhd') filesep 'Figures'],['RawTraces']);
