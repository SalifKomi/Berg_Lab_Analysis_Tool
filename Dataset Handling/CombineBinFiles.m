
function CombineBinFiles(flist,SavePath,Filename,format)
    mkdir(SavePath)
    fid_write = fopen([SavePath '/' Filename '.bin'], 'w');
    for j = 1:length(flist)
        fid_read = fopen([flist(j).folder '/' flist(j).name]);
        A = fread(fid_read, '*int16');
        fwrite(fid_write, A, 'int16')
        fclose(fid_read)
    end
    fclose(fid_write)  
    for i = 1:length(flist)
        delete([flist(i).folder filesep flist(i).name]);
    end  
end