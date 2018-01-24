function [spikeTimes,spikeClusters] = extractSpikesAndClusters(pathFile)

% extract spike times and spike clusters
cd(pathFile)

spikeTimes = readNPY('spike_times.npy'); % these are in samples, not seconds
spikeClusters = readNPY('spike_clusters.npy');