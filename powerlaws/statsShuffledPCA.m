% compute cross-validated PCs and signal variance and SNR and
% responsiveness
function statsShuffledPCA(dataroot, matroot)

load(fullfile(dataroot,'dbstims.mat'));

%%
nstims = 2800;

clf;
for K = 1:6
    clf;
    load(fullfile(matroot,sprintf('%s_proc.mat',stimset{K})));
    %%
    for k = 1:numel(find(stype==K))
		%%
        A = double(respAll{k});
		
		% correlation computation
		Vexp = zeros(size(A,2), 1);
        pNeu = zeros(size(A,2), 1);
        for i = 1:size(A,2)
            [Vexp(i), pNeu(i)]  = corr(A(:,i,1), A(:,i,2));
        end
        Rx{K}{k}     = Vexp;
		Px{K}{k}     = pNeu;
        
			
			
		% SNR computation
		vnoise = var(A(:,:,1) - A(:,:,2), 1, 1) / 2;
		v1     = var(A(:,:,1), 1, 1);
		v2     = var(A(:,:,2), 1, 1);
        snr{K}{k} = (v1 + v2 - 2*vnoise) ./ (2*vnoise);
        
		% signal variance computation
		Vx{K}{k} = mean((A(:,:,1) - mean(A(:,:,1),1)) .* (A(:,:,2) - mean(A(:,:,2),1)), 1) ./ ...
			(0.5 * (v1 + v2));
		
		% responsiveness computation
		A1 = mean(A, 3);
		amax = A1(1:end-1,:) > repmat(A1(end,:) + 2*std(A1(1:end-1,:),1,1), size(A1,1)-1, 1);
		mresp{K}(k) = mean(mean(amax(:,:),2));
		
		% cross-validated PCA computation
		nshuff = 10;
        ss0 = shuffledSpectrum(A, nshuff);
        ss  = nanmean(ss0,2);
        ss  = ss(:) / sum(ss);
        
        specS{K}{k} = ss; 
        
        loglog(specS{K}{k})
        hold all;
        axis tight;
        axis square;
        drawnow;
       
        alpha{K}(k) = get_powerlaw(specS{K}{k}, [11:min(500,numel(ss)-2)]);
        fprintf('%s stimvar: %0.3f power-law: %1.3f\n', stimset{K}, nanmean(Vx{K}{k}), alpha{K}(k));
	end
end

%%
save(fullfile(matroot,'eigs_and_stats_all.mat'), 'specS','Vx','Px','alpha','snr','mresp')
 