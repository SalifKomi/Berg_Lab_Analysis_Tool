%%%%%%%%%%%%%%% SCRIPT BY SALIF KOMI - BERG LAB 2022 %%%%%%%%%%%%%%%%%%%%%

function [varargout] = SaveIntanToBin(varargin)  
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
            SaveBinary(Bin,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Neural'],'int16');
    end
    %% Save Accelerometers
    if(~isempty(IntanData.aux_input_channels))
            Acc = IntanData.aux_input_data;
            SaveBinary(Acc,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Accel'],'double');
    end 
    %% Save Stimulation Matrix       if(size(IntanData.boar_adc_data,1) > 1)
    if(~isempty(IntanData.board_adc_data))
            if(size(IntanData.board_adc_data,1) > 0) 
                 Rec = IntanData.board_adc_data(1,:);
                 SaveBinary(Rec,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Rec'],'double');
%             else
%                  Rec = IntanData.board_adc_data(1,:);
%                  SaveBinary(Rec,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Rec'],'double');
            end
        %% Video Trigger 
           if(size(IntanData.board_adc_data,1) > 1) 
                Stim = IntanData.board_adc_data(2,:);
                SaveBinary(Stim,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Stim'],'double');
           else
                Stim = IntanData.board_adc_data(1,:);
                SaveBinary(Stim,IntanData.path(1:end-1),[erase(IntanData.filename,'.rhd'),'_Stim'],'double');
           end
    end
    
    Amplength = length(IntanData.amplifier_channels);
    Auxlength = length(IntanData.aux_input_channels);    
    ADClength = size(IntanData.board_adc_data,1);
    varargout = {Amplength,Auxlength,ADClength};
end
