%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% NETWORK CAUSALITY ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B = [];
SumMat = SumMat(ROI,:);
SumMat(SumMat > 1) = 1;
for n = 1:size(SumMat,2)
        X = SumMat;
        X(:,n) = [];
        Y = SumMat(:,n);
        B = [B glmfit(X,Y,'binomial')];
end

%% Quantify probable causality of a sequence 
Reward = [];
Seq = 1:length(SortingIndices);
Seq = perms(Seq);
Sequences = [];
for k = 1:size(Seq,1)
    Seqt = Seq(k,:);
    RSeq = 0;
    for i = 1:length(Seqt)-1
        RSeq = RSeq + GrangerF(Seqt(i+1),Seqt(i)); 
    end
    Reward = [Reward RSeq];
end

RSort = 0;
for i = 1:length(SortingIndices)-1
    RSort = RSort + GrangerF(SortingIndices(i+1),SortingIndices(i)); 
end

Reward = [Reward RSort];
