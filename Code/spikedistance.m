function D_matrix = spikedistance(allWaves,wavetypes)

%% load waveforms of interest (sua, mua etc.)
waveforms = []; wavedays = []; clustid = []; chanid = [];
wfs = allWaves.wfs;
for i=1:length(wavetypes)
    indx = strcmp(allWaves.label,wavetypes{i});
    waveforms = [waveforms; allWaves.wfs(indx,:)];
    wavedays = [wavedays; allWaves.day(indx,:)];
    clustid = [clustid; allWaves.id(indx)];
    chanid = [chanid; allWaves.channel(indx)];
end
nwaveforms = size(waveforms,1);
nt = size(waveforms,2);

%% normalise waveforms
waveforms = (waveforms./repmat(sqrt(sum(waveforms.^2,2)),[1 size(waveforms,2)]));

%% compute pairwise distance
wavediffs = nan(nwaveforms,nwaveforms);
for i=1:nwaveforms
    for j=1:nwaveforms
        wavediff = waveforms(i,:) - waveforms(j,:);
        wavediffs(i,j) = sqrt(sum(wavediff.^2));
    end
end