function [ClusterFiring] = GetGoodClustersFiring(spike_clusters,spike_times,clusters_id)
%% Inputs 
% spike_clusters is the template number of for each spike 
% spike_time is the time (in samples at which spike #n fired
% cluster_id is the group to which each cluster spikes belong (bad, noise,
% good)
    spike_group = [];
    %% Sort Time Series By clusters 
    Good_Clusters = clusters_id{1}([find(strcmp(string(clusters_id{9,:}),'good '))]);
    Bad_Clusters = clusters_id{1}([find(strcmp(string(clusters_id{9,:}),'noise'))]);
    %%
    for i = 1:length(spike_clusters)    
        if any(eq(spike_clusters(i),Good_Clusters))
            spike_group(i,1) = 1; 
        else
            spike_group(i,1) = 0; 
        end
    end
    ClusterFiring = [spike_times,spike_clusters,spike_group];
    ClusterFiring = sortrows(ClusterFiring,3);
    ClusterFiring = SplitVec(ClusterFiring,3);
    ClusterFiring = SplitVec(sortrows(ClusterFiring{2},2),2);
end