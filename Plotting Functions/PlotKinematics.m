function PlotKinematics(KinCoord) 

fc = 5;
fs = 30;

[b,a] = butter(6,fc/(fs/2),'Low');
KinCoord = filtfilt(b,a,KinCoord);

 ColNum = size(KinCoord,2);
 LinNum = size(KinCoord,1);
 xval = KinCoord(:,[1 3 5 7 9])- KinCoord(:,9);
 yval = KinCoord(:,[2 4 6 8 10])- KinCoord(:,10);
 tl = 100;
 
 figure 
 ax1 = axes();
 inter = [];
 for j = 1:LinNum
     for i = 1:2:ColNum-3
         plot(ax1,KinCoord(j,[i i+2]) - KinCoord(j,9),KinCoord(j,[i+1 i+3])- KinCoord(j,10),'Color',Colors().BergGray09,'Linewidth',1.5)
         hold on 
     end
     
     if j <= tl 
         inter = [1:j];
     else
         inter = [j-tl:j];
     end  
     plot(ax1,KinCoord(inter,1)- KinCoord(inter,9),KinCoord(inter,2)- KinCoord(inter,10),'Color',Colors().BergYellow)
     set(ax1, 'YDir','reverse')
     axis equal
     xlim([min(xval(:)) max(xval(:))])
     ylim([min(yval(:)) max(yval(:))])
     drawnow;
     pause(0.001)
     cla(ax1);
 end