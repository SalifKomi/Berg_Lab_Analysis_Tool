%% 
clear PC1 PC2 PC3 D1 D2 D3 D ind
%% Steady PCA 
WindowSize = Ops.fs;
ind = 1;
PCs = [];
shift = Ops.fs/4;
PCp = zeros(length(Data.UFiring),3,round(length(Data.UFiring)/shift));
for Shift = [1:shift:length(Data.UFiring)-WindowSize length(Data.UFiring)-WindowSize]
    NormMatGFs = Data.UFiring(Shift:Shift+WindowSize,:);
    [s,p,~] = pca(NormMatGFs - movmean(NormMatGFs,Ops.fs/4));  
    %PCs(:,:,ind) =  s(:,1:3);
    try
     PCp(Shift:Shift+length(p)-1,:,ind) = p(:,1:3);
    catch
        disp('failed');
    end
    ind = ind+1;
end
%%
test = mean(PCp,3);
test = movmean(test,Ops.fs/4);

%%
for i = 1:size(PCs,3)
    for j = 1:size(PCs,3)
        D(i,j) = subspace(normalize(PCs(:,:,i),1,'range'),normalize(PCs(:,:,j),1,'range'));
    end   
end