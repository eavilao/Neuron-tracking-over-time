function [spikeTimes,cluster_ids,clusters, sua_indx] = GetUnits_phy_WF(f_spiketimes, f_spikeclusters, f_clustergroups)

spikeTimes = readNPY(f_spiketimes);
cluster_ids = readNPY(f_spikeclusters);
clusters = readCSV(f_clustergroups);

sua_indx = find(strcmp({clusters.label},'good'));
for i = 1:length(sua_indx)
     sua(i).tspk = spikeTimes(cluster_ids == str2double(clusters(sua_indx(i)).id));
     sua(i).cluster_id = repmat(str2double(clusters(sua_indx(i)).id),[size(sua(i).tspk),1]);
end

mua_indx = find(strcmp({clusters.label},'mua'));
for i = 1:length(mua_indx)
    mua(i).tspk = spikeTimes(cluster_ids == str2double(clusters(mua_indx(i)).id));
    mua(i).cluster_id = repmat(str2double(clusters(mua_indx(i)).id),[size(mua(i).tspk),1]); 
end


