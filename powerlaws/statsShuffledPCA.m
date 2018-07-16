% compute all stats

clear all;

useGPU   = 1;
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp/';
matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';        

load(fullfile(dataroot,'dbstims.mat'));

stimset={'natimg2800','white2800','natimg2800_8D','natimg2800_4D','natimg2800_small','ori'};
%%
nstims = 2800;

%clear Vx specS ccdims ccrank pval
clf;
%clear p;
for K = 1:6
    clf;
    load(fullfile(dataroot,sprintf('%sProc.mat',stimset{K})));
    %%
    for k = 1:numel(find(stype==K))
        A = respAll{k};
		
		% signal variance computation
        Vexp         = diag(corr(A(:,:,1), A(:,:,2)));
        Vx{K}{k}     = Vexp;
        
		% SNR computation
		vnoise = var(A(:,:,1) - A(:,:,2), 1, 1) / 2;
		v1     = var(A(:,:,1), 1, 1);
		v2     = var(A(:,:,2), 1, 1);
        snr{K}{k} = (v1 + v2 - 2*vnoise) ./ (2*vnoise);
        
		% responsiveness computation
		A1 = mean(A, 3);
		amax = A1(1:end-1,:) > repmat(A1(end,:) + 2*std(A1(1:end-1,:),1,1), size(A1,1)-1, 1);
		mresp{K}(k) = mean(mean(amax(:,:),2));
		
		% cross-validated PCA computation
		nshuff = 20;
        ss0 = shuffledSpectrum(A, nshuff, useGPU);
        ss  = gather_try(nanmean(ss0,2));
        ss  = ss(:) / sum(ss);
        
        specS{K}{k} = ss; 
        
        loglog(specS{K}{k})
        hold all;
        axis tight;
        axis square;
        drawnow;
       
        alpha{K}(k) = get_powerlaw(specS{K}{k}, [5:min(500,numel(ss)-2)]);
        disp([K nanmean(Vexp) alpha{K}(k)]);
	end
end

%%
save(fullfile(matroot,'eigsAllStats.mat'), 'specS','Vx','alpha','snr','mresp')
 