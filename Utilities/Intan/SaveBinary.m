function SaveBinary(bin,path,filename)
    %SAVEBINARY Summary of this function goes here
    %   Detailed explanation goes here
    totName = strcat([path filesep filename '.bin']);
    fid = fopen(totName, 'w'); 
    fwrite(fid, bin, 'int16');
    fclose(fid);  
end

