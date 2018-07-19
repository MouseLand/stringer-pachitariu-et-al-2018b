% where data is stored (that you download from figshare)
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp/';        
% where processed data and results are saved
matroot  = '/media/carsen/DATA2/grive/10krecordings/stimResults/';

useGPU = 1;

% compute two repeats from sequence of stimuli and response 
% and subtracts spontaneous components
% saves in matroot/stimtype_proc.mat with variables respAll and istimAll
% respAll{k} is stims x neurons x 2 repeats
% istimAll{k} are the stimulus identities for images that were repeated
% twice (see fitGabors for usage)
compileResps(dataroot, matroot, useGPU);

% compute cross-validated PCs and signal variance and SNR and responsiveness
% saves in matroot/eigs_and_stats_all.mat
statsShuffledPCA(dataroot, matroot, useGPU);

% treat responses to 32 natural images repeated 96 times as 32*48 images
% repeated twice, and compute the cross-validated PCs
% saves in matroot/natimg32_reps.mat
natimg32PCA(dataroot, matroot, useGPU);

% decode responses to 2800 natural images from one repeat
% decoder correlates responses on first half to second half
% stimulus that is most correlated is the decoded stimulus
% saves in matroot/decoder2800.mat
decode2800(matroot);

%%

