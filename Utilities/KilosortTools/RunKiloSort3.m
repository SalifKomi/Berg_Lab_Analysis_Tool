%% you need to change most of the paths in this block
function RunKiloSort3(Data,DataRoot,Probe,SamplingFreq,varargin)
%% Set Root to Home
rootH = '/home/pingvin'; % path to temporary binary file (same size as data, should be on fast SSD)
for ii = 1:2:length(varargin) 
    switch(varargin{ii})
        case 'rootH'
            rootH = varargin{ii+1}; % path to temporary binary file (same size as data, should be on fast SSD)
    end
end

%% Set Parameters
%     addpath(genpath([rootH '/Kilosort'])); % path to kilosort folder
%     addpath(genpath([rootH '/npy-matlab'])); % for converting to Phy
    rootZ = DataRoot; % the raw data binary file is in this folde
%% Prepare Environement     
    Map = CreateChanMapFile(DataRoot,SamplingFreq,'Probe', Probe);
    ops = SetKiloSortConfig();
    chanMapFile = 'chanMap.mat';
    ops.trange    = [0 Inf]; % time range to sort
    ops.NchanTOT  = Map.NChannels; % total number of channels in your recording
    ops.fproc   = fullfile(rootH, 'temp_wh.dat'); % proc file on a fast SSD
    ops.chanMap = fullfile([rootZ filesep chanMapFile]);

    %% this block runs all the steps of the algorithm
%     
    fprintf('Looking for data inside %s \n', rootZ)
    % main parameter changes from Kilosort2 to v2.5
    ops.sig        = 20;  % spatial smoothness constant for registration
    ops.fshigh     = 300; % high-pass more aggresively
    ops.nblocks    = 5; % blocks for registration. 0 turns it off, 1 does rigid registration. Replaces "datashift" option. 
    % main parameter changes from Kilosort2.5 to v3.0
    ops.Th       = [8 6];
    % find the binary file
    ops.fbinary  = [rootZ filesep Data];
    
%% Fix Version of KiloSort 3 
    rez                = preprocessDataSub(ops);
    rez                = datashift2(rez, 1);

    [rez, st3, tF]     = extract_spikes(rez);

    rez                = template_learning(rez, tF, st3);

    [rez, st3, tF]     = trackAndSort(rez);

    rez                = final_clustering(rez, tF, st3);

    rez                = find_merges(rez, 1);
%%
% % preprocess data to create temp_wh.dat
% rez = preprocessDataSub(ops);
% %
% % NEW STEP TO DO DATA REGISTRATION
% rez = datashift2(rez, 1); % last input is for shifting data
% 
% % ORDER OF BATCHES IS NOW RANDOM, controlled by random number generator
% iseed = 1;
%                  
% % main tracking and template matching algorithm
% rez = learnAndSolve8b(rez, iseed);
% 
% % OPTIONAL: remove double-counted spikes - solves issue in which individual spikes are assigned to multiple templates.
% % See issue 29: https://github.com/MouseLand/Kilosort/issues/29
% %rez = remove_ks2_duplicate_spikes(rez);
% 
% % final merges
% rez = find_merges(rez, 1);
% 
% % final splits by SVD
% rez = splitAllClusters(rez, 1);
% 
% % decide on cutoff
% rez = set_cutoff(rez);
% % eliminate widely spread waveforms (likely noise)
% rez.good = get_good_units(rez);
% 
% fprintf('found %d good units \n', sum(rez.good>0))
% 
% % correct times for the deleted batches
% rez = correct_time(rez);
% 
% % rewrite temp_wh to the original length
% rewrite_temp_wh(ops)
% 
% write to Phy
fprintf('Saving results to Phy  \n')
rezToPhy(rez, rootZ);
    
end

%% 
