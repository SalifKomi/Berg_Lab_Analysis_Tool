%REMEMBER TO CONVERT TO INT16
%Nicolas Bertram
%Run this script AFTER reading Intan files: read_Intan_RHD2000_file.m
%NB: Data might have accelerometer data mixed in, hence the initial slicing
%Remember to adapt the folder structure

function [newInt] = ConvertIntanMatToRawBinary(IntanData)
    newInt = int16(IntanData.amplifier_data);%((length(IntanData.amplifier_data)-128)+1:end));
    if (length(IntanData.amplifier_channels)>128)
         disp("Warning, # of channels excede 128 - slicing first channels off.."); 
    %         %If first channels include other data (e.g. accelometer)
            newInt = newInt( (length(IntanData.amplifier_channels) - 128) +1 :end ,1:end);
    end
end 