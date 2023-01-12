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
    if(~isempty(IntanData.amplifier_channels))
            Bin = ConvertIntanMatToRawBinary(IntanData);
            SaveBinary(Bin,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Bin'],'int16');
    end
    %% Save Accelerometers
    if(~isempty(IntanData.aux_input_channels))
            Acc = IntanData.aux_input_data;
            SaveBinary(Acc,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Accel'],'double');
    end 
    %% Save Stimulation Matrix       if(size(IntanData.boar_adc_data,1) > 1)
    if(~isempty(IntanData.board_adc_data))
            if(size(IntanData.board_adc_data,1) > 0) 
                 Stim = IntanData.board_adc_data(1,:);
                 SaveBinary(Stim,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Rec'],'double');
            end
        %% Video Trigger 
           if(size(IntanData.board_adc_data,1) > 1) 
                Vid = IntanData.board_adc_data(2,:);
                SaveBinary(Vid,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Stim'],'double');
           end
    end
end
