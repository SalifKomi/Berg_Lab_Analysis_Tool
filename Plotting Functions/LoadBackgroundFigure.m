% This creates the 'background' axes
function [fig,ha] = LoadBackgroundFigure()
ha = axes('units','normalized','position',[0 0 1 1]);uistack(ha,'bottom');
I=imshow('NetworkBackground.png');
truesize
set(ha,'handlevisibility','off','visible','off')
fig = gcf;
end