function CorrMat = ComputeStimFiringCorrelation(FiringRateMatrix,StimVector)
    CorrMat = [];
    for i = 1:size(FiringRateMatrix,2)
            R = corrcoef(FiringRateMatrix(:,i),StimVector(1:length(FiringRateMatrix(:,i)))); 
            CorrMat = [CorrMat R(1,2)];
    end 
end
