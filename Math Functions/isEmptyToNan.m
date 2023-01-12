function x = isEmptyToNan(Data)
    if(isempty(Data)) 
        x = NaN; 
    else
        x = Data;
    end
end