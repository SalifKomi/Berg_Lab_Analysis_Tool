function WritePhyParamsFile(file,path,varargin)
    fid = fopen([path '\params.py'],'W');

    dat_path = ['dat_path =' file];
    n_channels = ['n_channels_dat = 128'];
    dtype = ['dtype = Int16'];
    offset = ['offset = 0 '];
    sample_rate = ['sample_rate = 20000'];
    hp_filtered = ['hp_filtered = False'];


    for i = 1:2:length(varargin)
        switch varargin{i}
            case 'n_channels'
                n_channels = ['n_channels_dat =' num2str(varargin{i+1})];            
            case 'dtype'
                dtype = ['dtype =' varargin{i+1}];
            case 'offset'
                offset = ['offset = ' num2str(varargin{i+1})];
            case 'sample_rate'
                sample_rate = ['sample_rate = ' num2str(varargin{i+1})];
            case 'hp_filtered'
                hp_filtered = ['hp_filtered = ' varargin{i+1}];
        end
    end

    fprintf(fid,'%s\n',dat_path);
    fprintf(fid,'%s\n',n_channels);
    fprintf(fid,'%s\n',dtype);
    fprintf(fid,'%s\n',offset);
    fprintf(fid,'%s\n',sample_rate);
    fprintf(fid,'%s\n',hp_filtered);
    fclose(fid);
end