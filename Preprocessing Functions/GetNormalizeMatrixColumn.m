function NormMatrix = GetNormalizeMatrixColumn(Matrix) % Soft Normalization
    NormMatrix = [];
    for n = 1:size(Matrix,2)
%         NormMatrix = [NormMatrix (Matrix(:,n)-min(Matrix(:,n)))./(max(Matrix(:,n))-min(Matrix(:,n)))];
        NormMatrix = [NormMatrix (Matrix(:,n))./(range(Matrix(:,n)) + 5)];
    end 
end