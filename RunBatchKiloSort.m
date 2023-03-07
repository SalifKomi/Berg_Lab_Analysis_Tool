FolderContent = uigetdir(); 
FileList = dir(fullfile(FolderContent,'**','*.bin'));
for i = 1:length(FileList)
    clearvars -except FileList FolderContent i
    close all
    try 
        RunKiloSort3(FileList(i).name,FileList(i).folder,'Neuropixel',30000);
    catch Err
        disp(Err.identifier)
    end
end