function [Data,Ops] = LoadData(Folder,Ops)
if exist([Folder filesep 'AlignedData'], 'dir')
    FileContent = dir([Folder filesep 'AlignedData']);
else 
    FileContent = dir([Folder]);
end
%%%%%%%%%%%%%%%%%%%%%%%% LOAD SPIKING DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Data = struct();
    Ops.DataFolder = Folder;

    if Ops.flagspike
        Data.spike_clusters = readNPY([FileContent(1).folder filesep 'spike_clusters.npy']);
        Data.spike_times = readNPY([FileContent(1).folder filesep 'spike_times.npy']);
        Data.spike_amplitude =  readNPY([FileContent(1).folder filesep 'amplitudes.npy']);
        Data.spike_templates = readNPY([FileContent(1).folder filesep 'spike_templates.npy']);
        Data.templates = readNPY([FileContent(1).folder filesep 'templates.npy']);
        Data.chan_pos = readNPY([FileContent(1).folder filesep 'channel_positions.npy']);
        Data.clusters_info = struct2cell(tdfread([FileContent(1).folder filesep  'cluster_info.tsv']));
        Data.clusters_id = Data.clusters_info{1,1};
        Data.clusters_id = Data.clusters_id([find(contains(string(Data.clusters_info{9,:}),'good'))]);
        Data.clusters_channels = Data.clusters_info{6,1};
        Data.clusters_channels = Data.clusters_channels([find(contains(string(Data.clusters_info{9,:}),'good'))]);        
    end
    
    if Ops.flaglfp 
        lfp_fid = fopen([FileContent(1).folder filesep FileContent(contains({FileContent.name},'Lfp')).name]);
        lfp = fread(lfp_fid,'int16');
        fclose(lfp_fid);    
        lfp = reshape(lfp,384,length(lfp)/384);
        lfp = lfp';
        Data.lfp = lfp; 
    end
%%%%%%%%%%%%%%%%%%%%%%%% LOAD REC REF FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if Ops.flagrec
        rec_times_fid = fopen([FileContent(1).folder filesep FileContent(contains({FileContent.name},'Rec')).name]);
        Data.rec_times = fread(rec_times_fid,'double');
        fclose(rec_times_fid);   
    end

%%%%%%%%%%%%%%%%%%%%%%% LOAD STIM DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Ops.flagstim 
       stim_times_fid = fopen([FileContent(1).folder filesep FileContent(contains({FileContent.name},'Stim')).name]);
       Data.stim_times = fread(stim_times_fid,'double');
       fclose(stim_times_fid);   
    end 
%%%%%%%%%%%%%%%%%%%%%%% LOAD KINEMATIC DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Ops.flagkin
        if any([FileContent(1).folder filesep '*xypts.csv'])
            ind = find(contains({FileContent.name},'xypts.csv'));
            Data.KinCoord = readmatrix([FileContent(1).folder filesep FileContent(ind).name]);
            Data.KinCoord = resampc(size(Data.KinCoord,1),Data.KinCoord,size(Data.KinCoord,1)*(Ops.fs/Ops.kfs));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%% LOAD VIDEO OBJECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Ops.flagvid 
        vid = dir([Folder '/*.mp4']);
        Data.Video = VideoReader([vid.folder filesep vid.name]);
        Ops.vfr = Data.Video.FrameRate;
        Ops.vst = Data.Video.CurrentTime;
    end
end