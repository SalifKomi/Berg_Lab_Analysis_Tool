function Parameters = ComputeKinematicParameters(KinCoord,Cycles) 
    Parameters = table();
    for i = 1:length(Cycles.Start)
    %% Compute Step length
        Parameters.SL(i) = norm(KinCoord(Cycles.End(i),[1 2]) - KinCoord(Cycles.Start(i),[1 2]));
    %% Compute Step Height
       % Parameters.SH(i) = 
    %% Compute Speed 
        %Parameters.speed(i) = 
    end
end