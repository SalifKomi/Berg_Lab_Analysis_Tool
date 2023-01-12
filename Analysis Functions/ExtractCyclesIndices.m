function [CycleInd,NonCycleInd] = ExtractCyclesIndices(Cycles,low,up,fs)
    CycleInd = [];
    NonCycleInd = [];

    for i = 1:length(Cycles.Start)-1        
        if(Cycles.Start(i+1)-Cycles.Start(i)) < up*fs & (Cycles.Start(i+1)-Cycles.Start(i)) > low*fs
            CycleInd = [CycleInd {Cycles.Start(i):Cycles.Start(i+1)}];
        else
            NonCycleInd = [NonCycleInd {Cycles.Start(i):Cycles.Start(i+1)}];
        end 
    end
end