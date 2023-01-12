function ThreshUnit = GetThreshUnits(FiringRateMatrix,Thresh)
    if(isempty(Thresh))
        Thresh = 0;
    end
    MaxF = max(FiringRateMatrix,[],1);
%     FRMRoi = FiringRateMatrix(:,(MaxF > Thresh));
    ThreshUnit = (MaxF > Thresh);
end