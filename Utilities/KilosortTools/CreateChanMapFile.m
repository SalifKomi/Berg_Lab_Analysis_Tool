%  create a channel map file
function [Map] = CreateChanMapFile(DataRoot,SamplingFreq,varargin)

Probe = 'Default';
for ii = 1:2:length(varargin) 
    switch(varargin{ii})
        case 'Probe'
            Probe = varargin{ii+1};
    end 
end

xcoords = [];
ycoords = [];
kcoords = [];

switch Probe
   case 'NeuronexusBerg16x8'    
        load('/home/pingvin/Berg_Lab_Analysis_Tool/Utilities/KilosortTools/ChannelMaps/NeuronexusBerg16x8.mat')
        fs = SamplingFreq;
        Nchannels = length(xcoords);
   case 'Neuronexus'
        load('/home/pingvin/Berg_Lab_Analysis_Tool/Utilities/KilosortTools/ChannelMaps/Neuronexus.mat')
        fs = SamplinfFreq;
        Nchannels = length(xcoords);
   case 'Linear32'
        load('/home/pingvin/Berg_Lab_Analysis_Tool/Utilities/KilosortTools/ChannelMaps/Linear32kilosortChanMap.mat')
        fs = SamplingFreq;
        Nchannels = length(xcoords);      
   case 'Neuropixel'   
        load('/home/pingvin/Berg_Lab_Analysis_Tool/Utilities/KilosortTools/ChannelMaps/neuropixPhase3B2_kilosortChanMap.mat')
        fs = SamplingFreq;
        Nchannels = length(xcoords)+1;
        %connected(120:end) = 0;
    otherwise       
    Nchannels = 128;
    fs = SamplingFreq;
    connected = true(Nchannels, 1);
    chanMap   = 1:Nchannels;
    chanMap0ind = chanMap - 1;
    xcoords   = ones(Nchannels,1);
    ycoords   = 20*([1:Nchannels]');
    kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)
end 
save([DataRoot filesep 'chanMap.mat'],'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')
disp(['Generated Channel Map for ' Probe]);

Map = struct();
Map.NChannels = Nchannels; 
Map.fs = fs; 
Map.connected = connected; 
Map.chanMap = chanMap;
Map.chanMap0ind = chanMap0ind;
Map.xcoords = xcoords; 
Map.ycoords = ycoords; 
Map.kcoords = kcoords; 

%%

% kcoords is used to forcefully restrict templates to channels in the same
% channel group. An option can be set in the master_file to allow a fraction 
% of all templates to span more channel groups, so that they can capture shared 
% noise across all channels. This option is

% ops.criterionNoiseChannels = 0.2; 

% if this number is less than 1, it will be treated as a fraction of the total number of clusters

% if this number is larger than 1, it will be treated as the "effective
% number" of channel groups at which to set the threshold. So if a template
% occupies more than this many channel groups, it will not be restricted to
% a single channel group. 