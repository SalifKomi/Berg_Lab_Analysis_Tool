%% Spatial Analysis
%% Plot Spatial PC
 pctt = double(length(Data.UFiring)/100); % Percent of the recording duration
 pcts = double(ceil(range(Data.chan_pos(:,2))/100)); % spatial percentage
[cluster_chan,SortingIndices] = sort(Data.clusters_channels);
% for ws = 10:10:100
%     for s_min = 0:10:100-ws
        TOI = [697.5 705];
        ROIs = min(Data.chan_pos(:,2)) +pcts.*[0 100];
        ROIt = pctt.*100*TOI/(size(Data.UFiring,1)/Ops.fs) +[1 0];%[82.08 87.5];
        %so = Data.stim_on(ROIt(1):ROIt(2));
        % Spatial Sorting 
        CI = find((Data.chan_pos(:,2)>= ROIs(1)) & (Data.chan_pos(:,2) <= ROIs(2)));
        SInd = ismember(Data.clusters_channels(Data.UoI),CI);
        if(~isempty(find(SInd)))
            US = Data.USpiking(ROIt(1):ROIt(2),find(SInd));
            MatGFs = Data.UFiring(ROIt(1):ROIt(2),find(SInd));
            N = rmmissing(normalize(MatGFs-movmean(MatGFs,Ops.fs/2) ,2,"zscore"),2);
            %[c,s,l] = pca(MatGFs-movmean(MatGFs,Ops.fs/2));
            [c,s,l] = pca(N);

            %[reduction, umap, clusterIdentifiers, extras] = run_umap(s(1:10:end,1:3),'min_dist',0.1,'n_neighbors',190,'metric','cosine','init','spectral','n_components',3,'n_epochs',500);
            SI = GetFiringPhaseSorting(N,Ops,'Method','Correlation','Source',s(:,1));     
            fig = figure('Color','white','Position',[0,0,Ops.screensize(3)/3, Ops.screensize(4)]);
            plot3(s(:,1),s(:,2),s(:,3),'Color',Colors().BergGray05,'LineWidth',2 )    
            hold on
            view(180,0);
            save2pdf(fig,[Ops.DataFolder filesep 'Figures'],['Mice_Cycle_Trajectory_Ball'],'-dpdf');

            
%% Plot Subspace
%             ROIsp = min(Data.chan_pos(:,2)) +pcts.*[0 70];
%             CI = find((Data.chan_pos(:,2)>= ROIsp(1)) & (Data.chan_pos(:,2) <= ROIsp(2)));
%             SInd = ismember(Data.clusters_channels,CI);
%             Ntp = N;
%             Ntp(:,find(SInd)) = 0;
%             NNtp = Ntp*c;
%             plot3(NNtp(:,1),NNtp(:,2),NNtp(:,3))
%             axis square
% %             axis equal
%             figure
%             PlotRaster(US(:,SI)');
%             colormap('viridis')
            
            %%
            
            fig = figure('Color','white','Position',[0,0,Ops.screensize(3)/1.5, Ops.screensize(4)/4]);
            Firing = normalize(MatGFs,'range');
            Firing = rmmissing(Firing(:,SI)',2);
            [X,Y] = meshgrid(1:size(Firing,1),1:size(Firing,2));
            [Xq,Yq] = meshgrid(1:1:size(Firing,1),1:size(Firing,2));
            Firing = interp2(X,Y,Firing',Xq,Yq);
            imagesc(exp(Firing'))
            colormap(viridis);

            yticks(1:10:size(Firing,2))
            yticklabels(1:10:size(Firing,2))
            ylabel('Nth-Neuron');
            xticks(0:Ops.fs:size(Firing,1));
            xticklabels(0:1:size(Firing,1)/Ops.fs);
            xlabel('Time [s]');
            save2pdf(fig,[Ops.DataFolder filesep 'Figures'],['Mice_FiringRates'],'-dpdf');

        else 
            disp('SInd is empty');
        end
%     end
% end