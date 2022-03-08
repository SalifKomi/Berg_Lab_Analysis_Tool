
Folder   = uigetdir() ;
FileList = dir(fullfile(Folder, '**', '*.rhd'));
for i = 1:length(FileList)
    try
        SaveIntanToBin([FileList(i).folder filesep FileList(i).name])
    catch ex
        disp(['File' FileList(i).name 'Failed at Saving due to' ex.identifier]);
    end
end

%%
Folder   = uigetdir() ;
FileList = dir(fullfile(Folder, '**', '*.bin'));


[rez, DATA, uproj] = preprocessData([FileList(1).folder filesep FileList(1).name]); % preprocess data and extract spikes for initialization
rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)