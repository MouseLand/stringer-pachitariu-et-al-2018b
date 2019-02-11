% simulations to validate cross-validated PCA method
% simulate 2P noise by filtering with exponential and then adding noise and
% deconvolving signals

function noiseSpectrum(matroot)

%% empirical noise spectrum

stimset={'natimg2800'};
load(fullfile(matroot,sprintf('%s_proc.mat',stimset{1})));

for k = 1:7
	[ss0,cproj,ns0]=shuffledSpectrum(respAll{k},10);
	ns           = nanmean(ns0,2);
	ns           = ns / sum(ns);
	specNoise{k} = ns;
	if k==6
		cprojEx = cproj;
	end
end
%
	save(fullfile(matroot,'noiseSpectrum.mat'),'specNoise','cprojEx');
	
