% compute cross-validated PCs of z-scored data
function zscoredControl(matroot,useGPU)

load(fullfile(matroot,'natimg2800_proc.mat'));
load(fullfile(matroot,'eigs_and_stats_all.mat'));
    
%%
clf;
clear svar;
for k = 1:numel(respAll)
    specVar{k} = sort(Vx{1}{k},'descend');
	totVar{k} = 0.5 * (var(respAll{k}(:,:,1),1,1) + var(respAll{k}(:,:,2),1,1));
	noiseVar{k} = 0.5 * var(respAll{k}(:,:,1) - respAll{k}(:,:,2),1,1);
	sigVar{k} = totVar{k} - noiseVar{k};
	totVar{k} = sort(totVar{k},'descend');
	sigVar{k} = sort(sigVar{k},'descend');
    loglog(specVar{k});
    hold all;
	loglog(totVar{k});
	loglog(sigVar{k});
    drawnow;
    
end

% z-score neurons
clf;
for k = 1:numel(respAll)
    respN = respAll{k};
    
    nshuff = 10;
    respN = zscore(respN,1,1);
    [ss0,cproj] = shuffledSpectrum(respN, nshuff, useGPU);
    cproj = gather_try(cproj);
    ss = gather_try(nanmean(ss0,2));
    ss = ss(:) / sum(ss);
    
    specZ{k} = ss;
    
    loglog(specZ{k});
    hold all;
    drawnow;
end

%
save(fullfile(matroot,'zscored_spectrum.mat'),'specVar','specZ','sigVar');

