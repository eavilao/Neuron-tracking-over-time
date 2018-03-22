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
    waveForms(fileNum).wfs = wfs.waveForms; 
    
    % find waveform per channel
    for clusterID = 1:length(wfs.waveFormsMean)
        [~,bestchannel] = sort(max(squeeze(wfs.waveFormsMean(clusterID,:,:))') - min(squeeze(wfs.waveFormsMean(clusterID,:,:))'),'descend');
        bestchannel = bestchannel(1);
        waveforms(fileNum).clusters(clusterID).bestchannel = bestchannel;
    end
    % extract waveforms per cluster id
    disp(['Time before reshaping = ' num2str(toc)]); 
    allWaves.waves = [];
    for clusterNum = 1:length(clusters)
        waveforms(fileNum).meanWave(clusterNum,:) = squeeze(wfs.waveFormsMean(clusterNum,waveforms(fileNum).clusters(clusterNum).bestchannel,:));
        waves= (squeeze(wfs.waveForms(clusterNum,:,waveforms.clusters(clusterNum).bestchannel,:)))';
        allWaves.waves= [allWaves.waves;reshape(waves,numel(waves),[])]; 
    end
    disp(['Time until reshape = ' num2str(toc)]); 
    % write dat file
    %check for existind dat file 
    fOut = 'spike_waveforms.dat';
    dat_filename = dir(fOut);
    if isempty(dat_filename)
        disp(['spike_waveforms.dat not found!  Creating .dat file...'])
        fidW = fopen(fOut, 'a');
        dat = allWaves.waves;
        dat = int16(dat);
        fwrite(fidW, dat,'int16');
        fclose(fidW); % all done
        disp(['Time until .dat file = ' num2str(toc)]); 
    else
        disp(['spike_waveforms.dat file found! Overwriting .dat file...'])
        fidW = fopen(fOut, 'w+');
        dat = allWaves.waves;
        dat = int16(dat);
        fwrite(fidW, dat,'int16');
        fclose(fidW); % all done
        disp(['Time until .dat file = ' num2str(toc)]); 
    end
    
    % create xls file
    % if xls file exists, fill with nans then overwrite
    disp('Writing xls file...')
    fOut_xls = ('cluster_location.xls');
    xls_filename = dir(fOut_xls);
    if ~isempty(xls_filename)
        t = xlsread(fOut_xls);
        xlswrite(fOut_xls,zeros(size(t))*nan);
    end
    xls_headers = {'Cluster_ID' 'Ch_num' 'num_waves'}; 
    xlswrite(fOut_xls, xls_headers);
    xlswrite(fOut_xls, {waveforms.clusters.id}' ,'Sheet1','A2');
    xlswrite(fOut_xls, [waveforms(fileNum).clusters.bestchannel]','Sheet1','B2');
    xlswrite(fOut_xls, wfs.numSpikes','Sheet1','C2');
    disp(['Done: ']);
    disp(['Time to run file >> ' num2str(fileNum) ' <<  ('  monkeyInfo(fileNum).folder(end-10:end) ')  = ' num2str(toc)])
end


% allWaves.wfs = waveforms(1).meanWave;
% allWaves.day = waveforms(1).day(:,(end-67:end));
% allWaves.label = {waveforms(1).clusters.label}';
% allWaves.id = waveforms(1).unitIDs;
% allWaves.channel = [waveforms(1).clusters.bestchannel]';
% 
% for fileNum = 2:length(monkeyInfo)
% allWaves.wfs = [allWaves.wfs; waveforms(fileNum).meanWave];
% allWaves.day = [allWaves.day; waveforms(fileNum).day(:,(end-67:end))];
% allWaves.label = [allWaves.label;{waveforms(fileNum).clusters.label}'];
% allWaves.id = [allWaves.id ; waveforms(fileNum).unitIDs];
% allWaves.channel = [allWaves.channel ; [waveforms(fileNum).clusters.bestchannel]'];
% end
% 
% cd(resultsPath); 
% save('allWaves_Session_72_79.mat', 'allWaves', '-v7.3'); 
% disp(['Total time >> ' num2str(toc)]);
% %end