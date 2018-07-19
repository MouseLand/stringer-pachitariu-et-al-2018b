% treat responses to 32 natural images repeated 96 times as 32*48 images
% repeated twice, and compute the cross-validated PCs
function natimg32PCA(dataroot, matroot, useGPU)

load(fullfile(dataroot,'dbstims.mat'));

%%

nstims = 2800;
clf;
%clear p;
K = 7;
iexp = find(stype==K);
clf;
for k = 1:numel(iexp)
    fname = fullfile(dataroot, sprintf('%s_%s_%s.mat', stimset{K},...
        dbstims(iexp(k)).mouse_name, dbstims(iexp(k)).date));
        
    load(fname);
	
	% stimulus identities
    istim = stim.istim;
	
	% normalize by mean and std of spontaneous activity
	resp0   = stim.resp;
    mu      = mean(stim.spont, 1);
    sd      = std(stim.spont,1,1)+ 1e-6;
	resp0   = (resp0 - mu)./sd;
	nPCspont = 32; % number of components of spont to subtract
    
    resp0   = resp0 - mean(resp0,1);
    
	% split all stimulus responses into two halves
    i1 = [];
    i2 = [];
	A  = [];
    nStim = 32;
    for i = 1:nStim
        ix = find(istim==i);
        nstim = floor(numel(ix)/2);
        %ix = ix(randperm(numel(ix)));
        o1 = ix(1:nstim);
        o2 = ix(nstim + [1:nstim]);
        i1 = cat(1, i1, o1);
        i2 = cat(1, i2, o2);
	end
	A(:,:,1) = resp0(i1, :);
    A(:,:,2) = resp0(i2, :);
    
	% split into two halves and compute trial-averaged
    A1 = compute_means(istim, resp0, 2, 0);
	% A1 is stims x neurons x 2 where stims is 33
    ccSTIM      = corr(A1(1:nStim, :,1), A1(1:nStim, :, 2));
    fprintf('natimg32 trial-avg-stimvar: %2.2f\n', nanmean(diag(ccSTIM)))
            
	% subtract spontaneous subspace
	Fs0 = stim.spont;
    Fs0 = (Fs0 - mu)./sd;
	if useGPU
		Fs0 = gpuArray(single(Fs0));
	end
	[~, ~, Vspont] = svdecon(single(Fs0));
	Vspont = gather_try(Vspont);
	
	for i = 1:2
        A(:,:,i)  = A(:,:,i) - (A(:,:,i) * Vspont(:,1:nPCspont)) * Vspont(:,1:nPCspont)';
    end
    
    nshuff = 20;
    ss0 = shuffledSpectrum(A, nshuff, useGPU);
    ss = gather_try(nanmean(ss0,2));
	ss(ss<0) = 0;
    ss = ss(:) / sum(ss(ss>0));
    
	spec32{k} = ss;
	
    semilogx(cumsum(ss)); 
    hold all
	dat32{k} = A;
    drawnow
end

%%
save(fullfile(matroot, 'natimg32_reps.mat'),'spec32','dat32');
