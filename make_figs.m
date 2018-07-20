% where data is stored (that you download from figshare)
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp/';        
% where processed data and results are saved
matroot  = '/media/carsen/DATA2/grive/10krecordings/stimResults/';

%% makes fig1
fig1(dataroot, matroot);

%% makes fig2
fig2(dataroot, matroot);

%% makes fig3
fig3(dataroot, matroot);

%% makes fig4 (relies on saved structure from fig3 (matroot/alphas.mat)!)
fig4(matroot);

%% p-value and stim-related variance figure
suppfig_stimvar(matroot);

%% controls (z-scoring responses, subtracting spont PCs)
suppfig_controls_spontPCs(matroot);

%% low-rank receptive field figure
suppfig_RFs(matroot);

%% simulated data powerlaws
suppfig_simdata(matroot);

%% increasing neurons and stimuli
suppfig_incrNeuStim(dataroot,matroot);

%% statistics from gabor fits
suppfig_gabors(matroot);