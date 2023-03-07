path = '/media/pingvin/Elements/Neuropixel Data/RAT161/*DAY2/*/AlignedData';%'/home/pingvin/Documents/NeuropixelData/Day 2/CombinedAll';
SavePath = '/media/pingvin/Elements/Neuropixel Data/RAT161/DAY2/CombinedRotating';
FolderContent = path;

%% Dataset Name and content
Name = 'RAT161_DAY2_CombinedRotating_';
types = {'Rec','Stim','Data'}; % Can be 'Stim', 'Acc', 'Rec' ,'Data'
RecToCombine = 13:14;%length(flist)-2;
%%
for Type = types
Type = Type{1};
flist = dir(fullfile(FolderContent,'**',['*' Type '.bin']));
Filename = [Name Type '.bin'];
%%
    switch Type
        case 'Stim'
            format = 'double';
        case 'Data'
            format = 'int16';
        case 'Rec' 
            format = 'double';
        case 'Acc'
            format = 'double';
    end
    mkdir(SavePath)
    fid_write = fopen([SavePath '/' Filename], 'w');
    for j = RecToCombine
        fid_read = fopen([flist(j).folder '/' flist(j).name]);
        A = fread(fid_read, ['*' format]);
        fwrite(fid_write, A, format)
        fclose(fid_read)
    end
    fclose(fid_write)
end