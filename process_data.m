% where data is stored (that you download from figshare)
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp/';        
% where processed data and results are saved
matroot  = '/media/carsen/DATA2/grive/10krecordings/stimResults/';
useGPU = 1;

%% SCRIPTS FOR MAIN ANALYSES AND FIGURES

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

% fits natural image responses using low-rank model of RFs
% saves in matroot/lowrank_fits.mat
fitLowRankRFs(dataroot,matroot,useGPU);

% fits gabors to natural image responses
% each cell is a simple + complex cell with fit scaling constants
% saves in matroot/gabor_fits.mat
fitGaborRFs(dataroot,matroot,useGPU);

% computes responses of gabor model to image stimuli fit to mouse which was
% shown all 6 different image sets 
% saves in matroot/gabor_spectrum.mat
simGaborFits(dataroot, matroot, useGPU);

% compute cross-validated PCs for varying numbers of neurons and stimuli
% saves in matroot/eigs_incneurstim_X.mat where X is stimset
incNeurStimPowerLaw(dataroot,matroot,useGPU);

% simulations of powerlaw with various tuning curves
fractalvmanifold(matroot)


%% SCRIPTS FOR SUPPLEMENTARY FIGURES




