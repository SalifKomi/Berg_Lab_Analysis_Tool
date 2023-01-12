%% Create Dataset Neuropixel 
np_fs = 30000;
intan_fs = 20000;   
lfp_fs = 2500;
aux_fs = 5000;
video_fs = 30;
channel_number = 384;
%% Search Files in Folder
FolderContent = uigetdir(); 
RecList = dir(fullfile(FolderContent,'recording*'));
%% Concatenate RHD Files for all Recording and Extract Stim, Rec, and Accel Data In Separated Files RUN ONCE!!
for el = 20 %1:8%length(RecList)-2
    Name = split(RecList(el).folder,'/');
    Name = Name{end};
    RecPath = [RecList(el).folder filesep RecList(el).name];
    rhdFileList = dir(fullfile(RecPath,'**','*.rhd'));
    for i = 1:length(rhdFileList)     
        try
            SaveIntanToBin([rhdFileList(i).folder filesep rhdFileList(i).name])
        catch ex
            disp(['File' rhdFileList(i).name 'Failed at Saving due to' ex.identifier]);
        end
    end 
    AccFiles = dir(fullfile(rhdFileList(1).folder,'**','*_Accel*'));
    StimFiles = dir(fullfile(rhdFileList(1).folder,'**','*_Stim*'));
    RecFiles = dir(fullfile(rhdFileList(1).folder,'**','*_Rec*'));   
    for files = {{AccFiles,'Acc'}, {StimFiles,'Stim'}, {RecFiles,'Rec'}}
        CombineBinFiles(files{1}{1},RecPath,[Name '_' RecList(el).name '_' files{1}{2}]);
    end
end
%% Load Rec File and determine ROI
for el = 5 %7 %length(RecList)-2
    % Setup Names and Paths
    RecPath = [RecList(el).folder filesep RecList(el).name];
    FileContent = dir(fullfile(RecPath));
    SavePath = [FileContent(1).folder filesep 'AlignedData'];
    Name = split(FileContent(1).folder,'/');
    SaveName = [Name{end-1} '_' Name{end}];
    Dlist = dir(fullfile([FileContent(1).folder '/*/*AP/'],'**','*continuous.dat'));
    LFPlist = dir(fullfile([FileContent(1).folder '/*/*LFP/'],'**','*continuous.dat'));
    
    % Load Rec Times
    rec_times_fid = fopen([FileContent(1).folder filesep FileContent(contains({FileContent.name},'Rec')).name]);
    rec_times = fread(rec_times_fid,'double'); fclose(rec_times_fid);
    rec_times = resampc(length(rec_times),rec_times,length(rec_times)*(np_fs/intan_fs),'Type','Linear');
    % Extract ROI 
    rng = range(rec_times);
    innov = find(rec_times > min(rec_times)+rng/2);
    start = innov(1);
    stop = innov(end);
    ROI = [start:stop];
    rec_times = rec_times(start:stop);
%     SaveBinary(rec_times, SavePath, [SaveName '_Rec'],'double');
% 
%    % Load Crop and Save the other files with respect to Rec ROI
%     stim_times_fid = fopen([FileContent(1).folder filesep FileContent(contains({FileContent.name},'Stim')).name]);
%     stim_times = fread(stim_times_fid,'double'); fclose(stim_times_fid);
%     if(~isempty(stim_times))    
%         stim_times = resampc(length(stim_times),stim_times,length(stim_times)*(np_fs/intan_fs),'Type','Linear');
%         stim_times = stim_times(start:stop);
%         SaveBinary(stim_times, SavePath,[SaveName '_Stim'] ,'double');
%     end
%         
    lfp_fid = fopen([LFPlist(1).folder '/' LFPlist(1).name]);
    lfp = fread(lfp_fid,'int16');fclose(lfp_fid);
    if(~isempty(lfp))
        lfp = reshape(lfp,channel_number,length(lfp)/channel_number);
        lfp = resampc(size(lfp,2),lfp',size(lfp,2)*(np_fs/lfp_fs),'Type','Linear');
        lfp = lfp(1:(stop-start)+1,:)';
        SaveBinary(lfp(:), SavePath, [SaveName '_Lfp'],'int16');
    end
    
%     data_fid = fopen([Dlist(1).folder '/' Dlist(1).name]);
%     data = fread(data_fid,'int16');fclose(data_fid);
%     if(~isempty(data))
% 
%         data = data(1:channel_number*((stop-start)+1));
%         SaveBinary(data, SavePath, [SaveName '_Data'],'int16');
%     end
end