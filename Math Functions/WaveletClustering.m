function Data =  WaveletClustering(Data,varargin)
    TOI = 1:length(Data.UFiring);
    ncluster = 3;
    for ii = 1:2:length(varargin)
        switch varargin{ii}
            case 'TOI'
                TOI = varargin{ii+1};
            case 'ncluster'
                ncluster = varargin{ii+1};
        end
    end

    Temp = squeeze(range(Data.templates,2));
    Templates = [];
    for i = 1:size(Temp,1)
        Templates = [Templates;Data.templates(i,20:end,find(Temp(i,:) == max(Temp(i,:))))/max(Temp(i,:))];
    end
    
    Coeffs = [];
    for wave = {'bior1.5','rbio1.3','sym3','coif4','db4'}
        Coeff = [];
        for j = 1:size(Templates,1)
            [ca,~] = dwt(Templates(j,:),wave{1});
            Coeff = [Coeff;ca];
        end
        Coeffs = [Coeffs Coeff];
    end
    
    mask = ismember(Data.spike_times,TOI);
    TSet = unique(Data.spike_templates(mask));
    
    Data.Template_Max = Templates;
    
    Temp2 = Templates(TSet+1,:);
    Coeffs = Coeffs(TSet+1,:);
    %Features = SymExp(2.*Temp2);
    %Features = Coeffs;
    Features = Temp2;

    %Features = normalize([Coeffs],'zscore');
    Features(isnan(Features)) = 0;
    %Features(Features < 0) = 0;

    [reductiontot, umaptot, clusterIdentifierstot, extrastot] = run_umap(double(Features),'min_dist',0.1,'n_neighbors',20,'metric','euclidean','init','spectral','n_components',2,'n_epochs',1000,'save_template_file','TempOr.mat','verbose','none'); 
    %inter = GCModulMax1(full(umaptot.search_graph));
    k = full(sum(umaptot.search_graph));
    twom = sum(k);
    B = umaptot.search_graph - k'*k/twom;
    [inter,Q,n_it] = iterated_genlouvain(B,30000,0,1,'moverandw',[]);

    inter = GCStabilityOpt(full(umaptot.search_graph),0.5:0.1:1);    
    Data.Template_Cluster = zeros(size(Data.templates,1),size(inter,2));
    for jj = 1:size(inter,1)
        Data.Template_Cluster(TSet(jj)+1,:) = inter(jj,:); 
    end
    
end 
%%
function M = SymExp(Mat)
mat = Mat(:);
M = [];
for ii = 1:length(mat)
    if(mat(ii) < 0)
        M(ii) = 1-exp(-mat(ii));
    elseif(mat(ii) > 0)
        M(ii) = exp(mat(ii))-1;
    else 
        M(ii) = 0;
    end
end
M = reshape(M,size(Mat));
end

