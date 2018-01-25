% getWaveForms params

%get dat filename
dat_filename = dir('*.dat');
dat_file = dat_filename.name; 

gwfparams.dataDir = pathFile;                                                                               % KiloSort/Phy output folder
gwfparams.fileName = dat_file;                                                                              % .dat file containing the raw 
gwfparams.dataType = 'int16';                                                                               % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = 96;                                                                                         % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-40 41];                                                                                 % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 2000;                                                                                       % Number of waveforms per unit to pull out
gwfparams.spikeTimes = spikeTimes;                                                                          % Vector of cluster spike times (in samples) same length as .spikeClusters  [2,3,5,7,8,9];   
gwfparams.spikeClusters = spikeClusters;                                                                    % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes  [1,2,1,1,1,2];    
