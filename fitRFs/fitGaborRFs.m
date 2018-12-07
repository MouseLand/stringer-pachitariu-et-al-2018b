%%% computes Gabor fits to neural activity based on responses to
%%% natimg2800, uses an additive model (simple + complex cell)

% * add divisive normalization fitting * %

function fitGaborRFs(dataroot,matroot,useGPU)

% load images
load(fullfile(dataroot, 'images_natimg2800_all.mat'));
% use left and center screen
imgs = imgs(:,1:180,:);
[Ly, Lx, nimg] = size(imgs);

% load neural responses
load(fullfile(matroot,sprintf('%s_proc.mat','natimg2800')));

%%
for wnorm = 0:1
	
	%%
	for k = 1:length(respAll)
		gpuDevice(1);
		
		respN    = respAll{k};
		
		% which images were presented twice during experiment
		istimN   = istimAll{k};
		img0     = (single(imgs(:,:,istimN)) - 128) / 64;
		
		% split images into two halves (train and test)
		ntrain = floor(size(respN,1)/2);
		imgtrain = (single(reshape(img0(:,:,1:ntrain), [], ntrain)));
		imgtest  = (single(reshape(img0(:,:,ntrain+[1:ntrain]), [], ntrain)));
		if useGPU
			imgtrain = gpuArray(imgtrain);
			imgtest = gpuArray(imgtest);
		end
		
		% split neural responses in half
		rtrain = mean(respN(1:ntrain,:,:),3);
		rtest = mean(respN(ntrain+[1:ntrain],:,:),3);
		NN    = size(rtrain,2);
		
		
		% subtract mean responses to images
		b = mean(rtrain,1);
		rtrain = rtrain - b;
		rtest  = rtest - b;
		
		% total train and test variance
		vvtest  = mean(rtest.^2,1);
		vvtrain = mean(rtrain.^2,1);
		
		
		%% estimate receptive fields
		[ycent, xcent] = estimateRFs(reshape(imgtrain,Ly,Lx,ntrain), rtrain);
		drawnow;
		
		% use RF center to specify X,Y to loop over with gabors
		xx = 20;
		yy = 15;
		yp = median(xcent) + [-yy:5:yy];
		xp = median(ycent) + [-xx:5:xx];
		
		
		%% different gabor parameters
		gb.fspat = [.01:.02:.13];
		gb.spat  = [3:3:12];
		gb.sratio = [1:.5:2.5];
		gb.ori   = [0:pi/8:(pi-pi/8)];
		gb.phase = [0:pi/4:(2*pi-pi/4)];
		
		% creates a grid of gabors
		[A,X] = gridGabor(Ly,Lx,gb.fspat,gb.spat,gb.sratio,gb.ori,gb.phase);
		
		if useGPU
			A = gpuArray(single(A));
			X = gpuArray(single(X));
		end
		
		
		%% compute gabors at each location and find best fit
		[vartrain,vartest,ybest,xbest,gbest,cbest,respG,respGT] = ...
			gaborFITRect(X, A, yp, xp, imgtrain, imgtest, rtrain, rtest, wnorm);
		
		%%
		if wnorm==1
			gbest0 = floor(gbest/2);
			gbest0 = [gbest0(:) gbest>size(A,2)];
			gbest = gbest0;
		else
			gbest = gbest(:);
		end
		% how complex is a cell
		crat = (cbest(:,1) ./ sum(cbest(:,1:2),2))';
		
		%% residuals and variance from single trial
		rtest1 = respN(ntrain+[1:ntrain],:,1);
		rtest2 = respN(ntrain+[1:ntrain],:,2);
		
		rtest1 = rtest1 - b;
		rtest2  = rtest2 - b;
		vvtest1  = nanmean(rtest1.^2,1);
		
		res1   = rtest1 - respGT';
		res2   = rtest2 - respGT';
		vvr = 1 - nansum(nansum(res1.*res2,1))/nansum(nansum(rtest1.*rtest2,1));
		
		fprintf('natimg2800 gabor RF varexp (normalized): %0.3f\n', mean(vvr));
		
		%% powerlaws
		tpred = cat(2, respG, respGT);
		tpred = tpred(vartest>.05,:);
		[u s v] = svdecon(tpred - mean(tpred,2));
		s = gather_try(s);
		s = diag(s).^2;
		
		%%
		% compile gabor RF stats, cRF are RFs
		[cRF, rfstats] = getGaborRFs(X, A, gbest(:,1), crat, [ybest xbest]);
		
		results.specS{k}   = s;
		results.rfstats{k} = rfstats;
		results.vtrain{k} = vartrain;
		results.vtest{k} = vartest;
		results.vtestExp{k} = vvr;
		results.bestGB{k} = gbest;
		results.bestC{k} =  cbest;
		
	end
	
	results.X = X;
	results.gb = gb;
	results.Ly = Ly;
	results.Lx = Lx;
	results.wnorm = wnorm;
	if wnorm
		save(fullfile(matroot,'gabor_fits_wnorm.mat'),'-struct','results');
	else
		save(fullfile(matroot,'gabor_fits.mat'),'-struct','results');
	end
	
	
end
