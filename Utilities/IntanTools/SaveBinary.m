function SaveBinary(bin,path,filename,format)
    %SAVEBINARY Summary of this function goes here
    %   Detailed explanation goes here
    mkdir(path);
    totName = strcat([path filesep filename '.bin']);
    fid = fopen(totName, 'w'); 
    fwrite(fid, bin, format);
    fclose(fid);  
end

