function [xp,yp,w,h] = ChangeCoordinates(x,y,w,h)
    xp = x;
    yp = 1-(y+h);
    h = h;
    w = w;
end