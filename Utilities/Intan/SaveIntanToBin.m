%%%%%%%%%%%%%%% SCRIPT BY SALIF KOMI - BERG LAB 2022 %%%%%%%%%%%%%%%%%%%%%

function SaveIntanToBin(varargin)  
    if(isempty(varargin))
        [file, path, filterindex] = ...
        uigetfile('*.rhd', 'Select an RHD2000 Data File', 'MultiSelect', 'off');
        tic;
        if (file == 0)
            return;
        end
        filepath = [path,file];
    else 
        filepath = varargin{1};
    end
    IntanData = read_Intan_RHD2000_file(filepath);
    %% Save Spiking Data
%     Bin = ConvertIntanMatToRawBinary(IntanData);
%     SaveBinary(Bin,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Bin']);
    %% Save Stimulation Matrix
    Stim = IntanData.board_adc_data;
    SaveBinary(Stim,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Stim']);
end
