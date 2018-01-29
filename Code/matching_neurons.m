%function [d, matching_neurons] = fname(folder)
tic
resultsPath = 'C:\Users\erico\Documents\GitHub\Neuron-tracking-over-time';
monkeyInfoFile_joysticktask;

waveforms(length(monkeyInfo)).unitIDs = [];
waveforms(length(monkeyInfo)).spikeTimeKeeps = [];
waveforms(length(monkeyInfo)).clusters = [];
waveforms(length(monkeyInfo)).day = [];
waveforms(length(monkeyInfo)).meanWave = [];

for fileNum = 1:length(monkeyInfo)
    disp([ 'Running file  >> ' num2str(fileNum) ' <<  ('  monkeyInfo(fileNum).folder(end-10:end) ')  of   ' num2str(length(monkeyInfo))]);
    % go to data folder
    pathFile = [monkeyInfo(fileNum).folder '\neural data\'];
    cd(pathFile)
    
    % Extract spike times and spike cluster ids
    [spikeTimes,spikeClusters] = extractSpikesAndClusters(pathFile);
    [~,~,clusters, sua_indx] = GetUnits_phy_WF('spike_times.npy','spike_clusters.npy','cluster_groups.csv'); %TODO add all clusters
    
    %extract all waveforms
    getWaveForms_prs;
    wfs = getWaveForms(gwfparams);
    
    % store data into structure
    waveforms(fileNum).clusters = clusters;
    waveforms(fileNum).day = monkeyInfo(fileNum).folder;
    waveforms(fileNum).day = repmat(waveforms(fileNum).day,size(wfs.unitIDs,1),1);
    waveforms(fileNum).unitIDs = wfs.unitIDs;
    waveforms(fileNum).spikeTimeKeeps = wfs.spikeTimeKeeps;
    
    % find waveform per channel
    for clusterID = 1:length(wfs.waveFormsMean)
        [~,bestchannel] = sort(max(squeeze(wfs.waveFormsMean(clusterID,:,:))') - min(squeeze(wfs.waveFormsMean(clusterID,:,:))'),'descend');
        bestchannel = bestchannel(1);
        waveforms(fileNum).clusters(clusterID).bestchannel = bestchannel;
    end
    % extract mean waveforms per cluster id
    for clusterNum = 1:length(clusters)
        waveforms(fileNum).meanWave(clusterNum,:) = squeeze(wfs.waveFormsMean(clusterNum,waveforms(fileNum).clusters(clusterNum).bestchannel,:));
    end 
    disp(['Time to run file >> ' num2str(fileNum) ' <<  ('  monkeyInfo(fileNum).folder(end-10:end) ')  = ' num2str(toc)])
end

allWaves.wfs = waveforms(1).meanWave; 
allWaves.day = waveforms(1).day(:,(end-67:end));
allWaves.label = {waveforms(1).clusters.label}'; 
allWaves.id = waveforms(1).unitIDs; 
allWaves.channel = [waveforms(1).clusters.bestchannel]';



for fileNum = [2:8] %2:length(monkeyInfo)
allWaves.wfs = [allWaves.wfs; waveforms(fileNum).meanWave];
allWaves.day = [allWaves.day; waveforms(fileNum).day(:,(end-67:end))];
allWaves.label = [allWaves.label;{waveforms(fileNum).clusters.label}'];
allWaves.id = [allWaves.id ; waveforms(fileNum).unitIDs];
allWaves.channel = [allWaves.channel ; [waveforms(fileNum).clusters.bestchannel]'];
end

cd(resultsPath); 
save('allWaves_first8sessions.mat', 'allWaves', '-v7.3'); 
disp(['Total time >> ' num2str(toc)]);
%end