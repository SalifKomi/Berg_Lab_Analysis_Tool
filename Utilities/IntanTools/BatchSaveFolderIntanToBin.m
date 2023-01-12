
Folder   = uigetdir() ;
FileList = dir(fullfile(Folder, '**', '*.rhd'));
for i = 1:length(FileList)
    try
        SaveIntanToBin([FileList(i).folder filesep FileList(i).name])
    catch ex
        disp(['File' FileList(i).name 'Failed at Saving due to' ex.identifier]);
    end
end 
