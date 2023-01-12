%% 
clear PC1 PC2 PC3 D1 D2 D3 D ind
%% Steady PCA 
WindowSize = 5*Ops.fs;
ind = 1;
PCs = [];
for shift = [1:Ops.fs/4:length(Data.UFiring)-WindowSize length(Data.UFiring)-WindowSize]
    NormMatGFs = Data.UFiring(shift:shift+WindowSize,:);
    [s,~,~] = pca(NormMatGFs - movmean(NormMatGFs,Ops.fs/4));  
    PCs(:,:,ind) =  s(:,1:3);
    ind = ind+1;
end

for i = 1:size(PCs,3)
    for j = 1:size(PCs,3)
        D(i,j) = subspace(normalize(PCs(:,:,i),1,'range'),normalize(PCs(:,:,j),1,'range'));
    end   
end