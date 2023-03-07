%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% PRE-PROCESSING BEFORE ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Data,Ops] = PreProcessDataset(Data,Ops)
    %% %%%%%%% Update Data and Ops fields according to content of Data.
    if Ops.flagrec
        Ops.pctt = double(length(Data.rec_times)/100); % Percent of the recording duration
        Ops.ROIt =  floor(Ops.pctt.*[Ops.t_min,Ops.t_max]) + [1 0]; %[26298000:28176940];% [1:4325600]+Offset; % ROI = 8450000:8540000; % ROI = 34040:275680; Region of Interest in samples [1:4325600]+254044 (Pixel realignement of neural data) 
        Data.rec_times = Data.rec_times(Ops.ROIt(1):Ops.ROIt(2));
        Data.rec_on = GetRecOn(Data.rec_times); 
    else 
        Ops.pctt = double(max(Data.spike_times)/100); % Percent of the recording duration
        Ops.ROIt =  floor(Ops.pctt.*[Ops.t_min,Ops.t_max]) + [1 0]; %[26298000:28176940];% [1:4325600]+Offset; % ROI = 8450000:8540000; % ROI = 34040:275680; Region of Interest in samples [1:4325600]+254044 (Pixel realignement of neural data) 
    end

    if Ops.flagstim
       Data.stim_times = Data.stim_times(Ops.ROIt(1):Ops.ROIt(2));
       Data.stim_on = GetStimOn(Data.stim_times,Ops.fs);
    end

    if Ops.flaglfp
        [bl,al] = butter(3,30/(Ops.fs/2),'low');
        [bh,ah] = butter(3,1/(Ops.fs/2),'high');
        templfp =  filtfilt(bl,al,Data.lfpUnFilt);
        templfp = filtfilt(bh,ah,templfp);
        Data.lfp = templfp(Ops.ROIt(1):Ops.ROIt(2),:);
    end
    
    if Ops.flagacc
        [bl,al] = butter(3,30/(Ops.fs/2),'low');
        [bh,ah] = butter(3,1/(Ops.fs/2),'high');
        tempAcc=  filtfilt(bl,al,Data.AccUnFilt);
        tempAcc = filtfilt(bh,ah,tempAcc);
        Data.Acc = tempAcc(Ops.ROIt(1):Ops.ROIt(2),:);
    end
    
    if Ops.flagneural
        [bl,al] = butter(2,15/(Ops.fs/2),'low');
        [bh,ah] = butter(2,5/(Ops.fs/2),'high');
        tempNeural =  filtfilt(bl,al,Data.NeuralUnFilt);
        tempNeural = filtfilt(bh,ah,tempNeural);
        Data.Neural = tempNeural(Ops.ROIt(1):Ops.ROIt(2),:);
    end
    
    
    
    if Ops.flagspike
        Ops.pcts = double(ceil(range(Data.chan_pos(:,2))/100)); % spatial percentage
        Ops.ROIs = min(Data.chan_pos(:,2)) + Ops.pcts.*[Ops.s_min,Ops.s_max];  
        %% Split Into clusters timing and identity and get Stim Innovation Signal
        ClusterTimes = GetGoodClustersFiring(Data.spike_clusters,Data.spike_times,Data.clusters_info);
        %% Reconstruct Instantaneous Firing Rates of Individual Clusters (Gaussian Cumulative) 
        [GaussianFiring,SpikeTrains] = cellfun(@(x) ComputeGaussianFiring(x(:,1),Ops.GaussianSmoothness,...
        Ops.fs,Ops.ROIt),ClusterTimes,'UniformOutput',false);
        %% Region and firing of interest
        Data.UFiring = cell2mat(GaussianFiring');
        Data.USpiking = cell2mat(SpikeTrains');
        %% Compute Channel Mean Firing
        [Cc,id] = sort(Data.clusters_channels);
        D = Data.UFiring(:,id);
        S = Data.USpiking(:,id);
        
        inter =  SplitVec([Cc D'],1);
        inter2 = cellfun(@(x) sum(x,1),inter','UniformOutput',false);
        Data.CFiring = cell2mat(inter2')';
        Data.CFiring(1,:) = [];
        
        interS =  SplitVec([Cc D'],1);
        interS2 = cellfun(@(x) any(x,1),interS','UniformOutput',false);
        Data.CSpiking= double(cell2mat(interS2')');
        Data.CSpiking(1,:) = [];
        
        Data.CChannels = unique(Cc,'stable');
        %%
        Data.UoI = GetThreshUnits(Data.UFiring,Ops.Thresh);
        Data.NormUFiring = GetNormalizeMatrixColumn(Data.UFiring - movmean(Data.UFiring,Ops.fs/2));
        %%  Perform PCA 
        %[Data.NormPCc,Data.NormPCs,Data.NormPCl] =  pca(Data.NormUFiring - movmean(Data.NormUFiring,Ops.fs)); % pca(Data.UFiring);   
        [Data.PCc,Data.PCs,Data.PCl] = pca(Data.UFiring - movmean(Data.UFiring,Ops.fs/2)); % pca(Data.UFiring);   
        %Data.CorrectedNormPC = Data.NormPCs - movmean(Data.NormPCs,0.75*Ops.fs);
        Data.CorrectedPC = Data.PCs - movmean(Data.PCs,0.75*Ops.fs);
        %Data.SortingIndices = GetFiringPhaseSorting(Data.UFiring,Ops);   
    end
end