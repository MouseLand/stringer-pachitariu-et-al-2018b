% compute all stats

clear all;

% datapath
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp';
matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';        

load(fullfile(dataroot,'dbstims.mat'));


stimset={'natimg2800','white2800','natimg2800_8D','natimg2800_4D','natimg2800_small','ori'};
useGPU=1;
%%
nstims = 2800;

%clear Vx specS ccdims ccrank pval
clf;

K = 1;
clf;
k=0;
load(fullfile(dataroot,sprintf('%sProc.mat',stimset{K})));
load(fullfile(matroot,'eigsAllStats.mat'));
    
%%
clf;
clear svar;
for k = 1:numel(respAll)
    specVar{k} = sort(Vx{K}{k},'descend');
  
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

% only keep neurons with > 10% signal variance
clf;
for k = 1:numel(respAll)
    respN = respAll{k};
    
    nshuff = 10;
    respN = respN(:,Vx{1}{k}>.1,:);
    [ss0,cproj] = shuffledSpectrum(respN, nshuff, useGPU);
    cproj = gather_try(cproj);
    ss = gather_try(nanmean(ss0,2));
    ss = ss(:) / sum(ss);
    
    specHighV{k} = ss;
    
    loglog(specHighV{k});
    hold all;
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


%% shuffle responses and compute power laws
clf;
for k = 1:numel(respAll)
    respN = respAll{k};
    for j = 1:size(respN,2)
        rperm = randperm(size(respN,1));
        for jj = 1:2
            respN(:,j,jj) = respN(rperm,j,jj);
        end
    end
    
    nshuff = 10;
    [ss0,cproj] = shuffledSpectrum(respN, nshuff, useGPU);
    cproj = gather_try(cproj);
    ss = gather_try(nanmean(ss0,2));
    ss = ss(:) / sum(ss);
    
    %sigvar = sum(respN(:,:,1) .* respN(:,:,2), 1);
    %sigvar = diag(sigvar);
    specShuff{k} = ss;
    
	respN = single(zscore(respN,1,1));
    [ss0,cproj] = shuffledSpectrum(respN, nshuff, useGPU);
    cproj = gather_try(cproj);
    ss = gather_try(nanmean(ss0,2));
    ss = ss(:) / sum(ss);
    specShuffZ{k} = ss;	
	
    loglog(specShuff{k});
	
    hold all;
	loglog(specShuffZ{k});
    drawnow;
end

%
save(fullfile(matroot,'controlSpecs.mat'),'specVar','specShuff','specShuffZ','specHighV','specZ','totVar','sigVar');

