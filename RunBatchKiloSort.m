FolderContent = uigetdir(); 
FileList = dir(fullfile(FolderContent,'**','*Data.bin'));
for i = 1:length(FileList)
    clearvars -except FileList FolderContent i
    close all
    try 
        RunKiloSort3(FileList(i).name,FileList(i).folder,'Linear32',20000);
    catch Err
        disp(Err.identifier)
    end
end