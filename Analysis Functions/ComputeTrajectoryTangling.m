function Q = ComputeTrajectoryTangling(Data1,samplepoint,delta_t) 
% This function calculates the tangling measure define in Russo et al 2018
% from an input matrix (Data1) from all points with respect to a reference point (samplepoint). 
    scalingfactor=rms(Data1);
    epsilon=.000001*scalingfactor(1);
    
    % Smooth the data for less noisy derivatives:
    for jj=1:size(Data1,2)
        Data1s(:,jj)= smoothdata( Data1(:,jj),'sgolay',500) ;
    end
    
    % Derivative:
    velocitys= (Data1s(2:end ,:) - Data1s(1:end-1 ,:))./delta_t;
    
    for ii=1:(size(Data1,1)-1)
        x_diff_dummy = (Data1s(samplepoint,1)-Data1s(ii,1)).^2 ; % This is the reference time that is shifted for the first dimension (jj=1)!
        
        for jj=2:size(Data1,2) % To add the dimension in Euclidean mean.
            x_diff_dummy= x_diff_dummy + (Data1s(samplepoint,jj)-Data1s(ii,jj)).^2 ;
        end
        x_diff(ii)=x_diff_dummy ; x_diff_dummy=[]; 
        
        velocity_diff_dummy = (velocitys(samplepoint,1)-velocitys(ii,1)).^2 ; % This is the reference time that is shifted for the first dimension (jj=1)!
        for jj=2:size(Data1,2)
            velocity_diff_dummy= velocity_diff_dummy + (velocitys(samplepoint,jj)-velocitys(ii,jj)).^2 ;
        end
        velocity_diff(ii)=velocity_diff_dummy ; velocity_diff_dummy=[];
        
        Q(ii) = velocity_diff(ii)./(x_diff(ii)+epsilon) ;
    end
    Q(samplepoint)=[];

%    figure(100)
%    subplot(131);plot(Data1(:,1), Data1(:,2) )
%    subplot(132);plot(velocitys(:,1) ); hold on
%    subplot(132);plot(velocitys(:,2) );
%    %subplot(132);plot(velocitys(:,3) ); hold off
%    subplot(133);semilogy(Q);

end



