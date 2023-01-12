lfp_fid = fopen('/media/pingvin/Elements/Neuropixel Data/RAT161/RAT161_17102022_DAY1/recording07/continuous/Neuropix-PXI-100.ProbeA-LFP/continuous.dat');
lfp = fread(lfp_fid,'int16');
fclose(lfp_fid)
[b,a] = butter(4,20/(2*2500),'low');
lfp = reshape(lfp,384,length(lfp)/384);
lfp = lfp';
flfp = lfp - movmean(lfp,2500/2);
flfpf = filtfilt(b,a,flfp);

range =    251203:261421;
[~,PC,~] = pca(flfpf(range,:));
