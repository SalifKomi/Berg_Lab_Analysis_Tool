function [  ] = save2pdf( fig,SavePath,filename,format)
%SAVE2PDF Summary of this function goes here
%   Detailed explanation goes here
%figure(fig.Number);
set(fig, 'Visible','off');
fig.Renderer ='painter';
drawnow;
set(fig,'Units','Inches');
pos = get(fig,'Position');
set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]); 
% set(findall(fig,'Type','Axes'), 'Color', Colors().BergGray09);
set(fig,'Color',gca().Color);
if ~exist(SavePath, 'dir')
    mkdir(SavePath)
end 
set(fig, 'InvertHardcopy', 'on');
print(fig,[SavePath filesep filename],format);
%exportgraphics(fig,[SavePath '\' filename '.' format])
end

