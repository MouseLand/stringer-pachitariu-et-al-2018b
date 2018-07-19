% computes responses of gabor model to image stimuli fit to mouse which was
% shown all 6 different image sets
function simGaborFits(dataroot, matroot, useGPU)

matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';

% Gabors from data
results = load(fullfile(matroot,'gabor_fits.mat'));

% mouse M170717_MP033 was shown all 6 image sets
% we will use its Gabors for the responses
dset   = 6;
bestGB = results.bestGB{dset};
A = results.rfstats{dset}(1:end-1,:);
X = results.X;
vtest   = results.vtest{dset};
NN = numel(results.vtest{dset});
cbest = results.bestC{dset};
bmax  = cbest(:,3:4);
cmax  = cbest(:,1:2);

	
% compute center-surround at position yp(iy), xp(ix)
fg1   = gaborReduced(A,X);
A2    = A;
A2(5,:) = A2(5,:) + pi/2;
fg2   = gaborReduced(A, X);

if useGPU
	fg1 = gpuArray(single(fg1));
	fg2 = gpuArray(single(fg2));
end

clf;
clear respG1 respG2;
for K = 1:7
	switch K
		case 1
			load(fullfile(dataroot, 'images_natimg2800_all.mat'));
		case 2
			load(fullfile(dataroot, 'images_natimg2800_white_all.mat'));
		case 3
			load(fullfile(dataroot, 'images_natimg2800_8D_M170717_MP033_2017-08-22.mat'));
		case 4
			load(fullfile(dataroot, 'images_natimg2800_4D_M170717_MP033_2017-09-19.mat'));
		case 5
			load(fullfile(dataroot, 'images_natimg2800_small_M170717_MP033_2017-08-23.mat'));
		case 6
			load(fullfile(dataroot, 'images_ori_all.mat'));
		case 7
			load(fullfile(dataroot, 'images_sparse_all.mat'));
	end
	
	img0 = (single(imgs) - 128) / 64;
	% only left and center screen
	img0 = img0(:,1:180,:);
	img0 = reshape(img0, [], size(img0,3));
	if useGPU
		img0 = gpuArray(single(img0));
	end
	
	respG1 = fg1' * img0;
	respG2 = fg2' * img0;
	respG2 = (respG1.^2 + respG2.^2).^.5;
	respG1 = max(0, respG1);
	respG2 = max(0, respG2);
	tpred  = cmax(:,1).*(respG1 - bmax(:,1)) + ...
		cmax(:,2).*(respG2 - bmax(:,2));
	tpred = gather(tpred);        
	        
	tpred = tpred(vtest>.05,:);
	
	whos tpred
	[u s v] = svdecon(tpred - mean(tpred,2));
	s = gather_try(s);
	s = diag(s).^2;
	
	trange0 =  [10:min(500,numel(s)-1)];
	[a,ypred,~,r] = get_powerlaw(s,trange0);
	
	subplot(1,7,K),
	loglog(s/sum(s));
	hold all;
	loglog(ypred/sum(s));
	title([a]);
	drawnow;
	alpha(K) = a;
	
	specS{K} = s / sum(s);
		
end

save(fullfile(matroot,'gabor_spectrum.mat'),'specS','alpha');
