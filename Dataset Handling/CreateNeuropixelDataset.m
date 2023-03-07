%% Create Dataset Neuropixel 
np_fs = 30000;
intan_fs = 20000;   
lfp_fs = 2500;
aux_fs = 5000;
video_fs = 30;
target_fs = intan_fs;
channel_number = 384;
%% Search Files in Folder
FolderContent = uigetdir(); 
RecList = dir(fullfile(FolderContent,'*freezing*'));
%% Concatenate RHD Files for all Recording and Extract Stim, Rec, and Accel Data In Separated Files RUN ONCE!!
for el = 1:length(RecList)
    Name = split(RecList(el).folder,'/');
    Name = Name{end};
    RecPath = [RecList(el).folder filesep RecList(el).name];
    rhdFileList = dir(fullfile(RecPath,'**','*.rhd'));
    for i = 1:length(rhdFileList)     
        try
            [NeuralChan, AccelChan] = SaveIntanToBin([rhdFileList(i).folder filesep rhdFileList(i).name]);
        catch ex
            disp(['File' rhdFileList(i).name 'Failed at Saving due to' ex.identifier]);
        end 
    end 
    AccFiles = dir(fullfile(rhdFileList(1).folder,'**','*_Accel*'));
    StimFiles = dir(fullfile(rhdFileList(1).folder,'**','*_Stim*'));
    RecFiles = dir(fullfile(rhdFileList(1).folder,'**','*_Rec*'));   
    BinFiles = dir(fullfile(rhdFileList(1).folder,'**','*_Neural*'));    
    for files = {{AccFiles,'Acc'}, {StimFiles,'Stim'}, {RecFiles,'Rec'}, {BinFiles,'Neural'}}
        CombineBinFiles(files{1}{1},RecPath,[Name '_' RecList(el).name '_' files{1}{2}]);
    end
end
%% Load Rec File and determine ROI
for el = 1:length(RecList)
    % Setup Names and Paths
    RecPath = [RecList(el).folder filesep RecList(el).name];
    FileContent = dir(fullfile(RecPath));
    SavePath = [FileContent(1).folder filesep 'AlignedData'];
    Name = split(FileContent(1).folder,'/');
    SaveName = [Name{end-1} '_' Name{end}];
    Dlist = dir(fullfile([FileContent(1).folder '/*/*AP/'],'**','*continuous.dat'));
    LFPlist = dir(fullfile([FileContent(1).folder '/*/*LFP/'],'**','*continuous.dat'));
    
    % Load Rec Times
    rec_times_fid = fopen([FileContent(1).folder filesep FileContent(contains({FileContent.name},'_Rec.bin')).name]);
    rec_times = fread(rec_times_fid,'double'); fclose(rec_times_fid); Or_length = length(rec_times);
    rec_times = resampc(length(rec_times),rec_times,length(rec_times)*(target_fs/intan_fs),'Type','Linear');
    % Extract ROI 
    rng = range(rec_times);
    innov = find(rec_times > min(rec_times)+rng/2);
    start = innov(1);
    stop = innov(end);
    ROI = [start:stop];
    rec_times = rec_times(start:stop);
    SaveBinary(rec_times, SavePath, [SaveName '_Rec'],'double');
 
   % Load Crop and Save the other files with respect to Rec ROI
    stim_times_fid = fopen([FileContent(1).folder filesep FileContent(contains({FileContent.name},'_Stim.bin')).name]);
    stim_times = fread(stim_times_fid,'double'); fclose(stim_times_fid);
    if(~isempty(stim_times))    
        stim_times = resampc(length(stim_times),stim_times,length(stim_times)*(target_fs/intan_fs),'Type','Linear');
        stim_times = stim_times(start:stop);
        SaveBinary(stim_times, SavePath,[SaveName '_Stim'] ,'double');
    end

   % Load Crop and Save the other files with respect to Rec ROI
    acc_times_fid = fopen([FileContent(1).folder filesep FileContent(contains({FileContent.name},'_Acc.bin')).name]);
    acc_times = fread(acc_times_fid,[AccelChan ,Or_length],'double'); fclose(acc_times_fid);
    if(~isempty(acc_times))    
        acc_times = resampc(length(acc_times),acc_times',length(acc_times)*(target_fs/aux_fs),'Type','Linear');
        acc_times = acc_times(start:stop,:);
        SaveBinary(acc_times, SavePath,[SaveName '_Acc'] ,'double');
    end
    
    % Load Crop and Save the other files with respect to Rec ROI
    neural_times_fid = fopen([FileContent(1).folder filesep FileContent(contains({FileContent.name},'_Neural.bin')).name]);
    neural_times = fread(neural_times_fid,[NeuralChan,Or_length],'int16'); fclose(neural_times_fid);
    if(~isempty(neural_times))    
        neural_times = resampc(length(neural_times),neural_times',length(neural_times)*(target_fs/intan_fs),'Type','Linear');
        neural_times = neural_times(start:stop,:);
        SaveBinary(neural_times, SavePath,[SaveName '_Neural'] ,'int16');
    end        
%         
%     lfp_fid = fopen([LFPlist(1).folder '/' LFPlist(1).name]);
%     lfp = fread(lfp_fid,'int16');fclose(lfp_fid);
%     if(~isempty(lfp))
%         lfp = reshape(lfp,channel_number,length(lfp)/channel_number);
%         lfp = resampc(size(lfp,2),lfp',size(lfp,2)*(target_fs/lfp_fs),'Type','Linear');
%         lfp = lfp(1:(stop-start)+1,:)';
%         SaveBinary(lfp(:), SavePath, [SaveName '_Lfp'],'int16');
%     end
%     
%     data_fid = fopen([Dlist(1).folder '/' Dlist(1).name]);
%     data = fread(data_fid,'int16');fclose(data_fid);
%     if(~isempty(data))
%         data = data(1:channel_number*((stop-start)+1));
%         SaveBinary(data, SavePath, [SaveName '_Data'],'int16');
%     end
end