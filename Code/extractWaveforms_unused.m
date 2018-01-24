function waveforms = extractWaveforms(sua_indx,clusters, pathFile)
getWaveForms_prs;
% Load .dat and KiloSort/Phy output
fileName = fullfile(gwfparams.dataDir,gwfparams.fileName);
filenamestruct = dir(fileName);
dataTypeNBytes = numel(typecast(cast(0, gwfparams.dataType), 'uint16')); % determine number of bytes per sample
nSamp = filenamestruct.bytes/(gwfparams.nCh*dataTypeNBytes);  % Number of samples per channel
wfNSamples = length(gwfparams.wfWin(1):gwfparams.wfWin(end));
mmf = memmapfile(fileName, 'Format', {gwfparams.dataType, [gwfparams.nCh nSamp], 'x'});
%chMap = readNPY([gwfparams.dataDir 'channel_map.npy'])+1;               % Order in which data was streamed to disk; must be 1-indexed for Matlab

% extract spike times and spike clusters
all_spikeTimes = readNPY('spike_times.npy'); % these are in samples, not seconds
all_spikeClusters = readNPY('spike_clusters.npy');

% read singleunit cluster
for neuronNum = 1:length(sua_indx)
    thisClusterID = str2double(clusters(sua_indx(neuronNum)).id);
    theseSpikeTimes = all_spikeTimes(all_spikeClusters == thisClusterID); % spike times for this ID
    extractSpikeTimes = theseSpikeTimes(1:100:end); %extract at most the first 100 spikes
    nWFsToLoad = length(extractSpikeTimes);
    wfWin = [-12:12]-102; % samples around the spike times to load   % TODO move to parameters
    nWFsamps = length(wfWin);
    theseWF = zeros(nWFsToLoad, nWFsamps);
    for i=1:nWFsToLoad
        tempWF(i,:) = mmf.Data.x(channelNumber,extractSpikeTimes(i)+wfWin(1):extractSpikeTimes(i)+wfWin(end));
    end
    wf_mean = nanmean(tempWF);
    waveforms(neuronNum,:)=wf_mean;
end
end