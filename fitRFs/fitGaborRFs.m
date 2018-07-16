%%% computes Gabor fits to neural activity based on responses to
%%% natimg2800, uses an additive model (simple + complex cell)

clear all;

matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp/';

useGPU = 1;

% load images
load(fullfile(dataroot, 'images_natimg2800_all.mat'));
% use left and center screen
imgs = imgs(:,1:180,:);
[Ly, Lx, nimg] = size(imgs);

% load neural responses
load(fullfile(dataroot,sprintf('%sProc.mat','natimg2800')));

%%
for k = 1:length(respAll)
    
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
    gb.fspat = [.01:.02:.12];
    gb.spat  = [1:3:12];
    gb.sratio = [1:.5:2.5];
    gb.ori   = [0:pi/8:(pi-pi/8)];
    gb.phase = [0:pi/8:(2*pi-pi/8)];
    
	% creates a grid of gabors
	[A,X] = gridGabor(Ly,Lx,gb.fspat,gb.spat,gb.sratio,gb.ori,gb.phase);
	
	if useGPU
        A = gpuArray(single(A));
        X = gpuArray(single(X));
    end
    
    
    %% compute gabors at each location and find best fit
	[vartrain,vartest,ybest,xbest,gbest,cbest,respG,respGT] = ...
		gaborFITRect(X, A, yp, xp, imgtrain, imgtest, rtrain, rtest);
		
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
	
	disp(mean(vvr));
    
	% compile gabor RF stats, cRF are RFs
	[cRF, rfstats] = getGaborRFs(X, A, gbest, crat, [ybest xbest]);
		
	results.rfstats{k} = rfstats;
	results.vtrain{k} = vartrain;
	results.vtest{k} = vartest;
	results.vtestExp{k} = vvr;
	results.bestGB{k} = gbest(:);
	results.bestC{k} =  cbest;

end

results.X = X;
results.gb = gb;
results.Ly = Ly;
results.Lx = Lx;

%%
save(fullfile(matroot,'gaborFits.mat'),'-struct','results');
 