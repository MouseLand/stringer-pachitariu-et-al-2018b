% fits natural image responses using low-rank model of RFs
function fitLowRankRFs(dataroot, matroot, useGPU)

% load images
load(fullfile(dataroot, 'images_natimg2800_all.mat'));
% use all screens
imgs = imgs(:,:,:);
[Ly, Lx, nimg] = size(imgs);

% load neural responses
load(fullfile(matroot,sprintf('%s_proc.mat','natimg2800')));

%%
for k = 1:length(respAll)
	
	%
	respN  = respAll{k};
	istimN = istimAll{k};
	
	% percent signal variance of each neuron 
	sigvar = corr(respN(:,:,1),respN(:,:,2));
	sigvar = diag(sigvar);
	
	Y = mean(respN,3); % take the mean over the two repeats
	% subtract mean response of each neuron across all images
	b0 = mean(Y,1);
	Y = Y - b0;
	NN = size(Y,2);
	
	%% find the principal components of the responses
	if useGPU 
		Y = gpuArray(single(Y));
	end
	[A B C] = svdecon(single(Y));
	% keep top 100 PCs of responses
	nPC = 100;
	V = A(:, 1:nPC) * B(1:nPC, 1:nPC);
	V = gather_try(V);	% images x components
	
	%% images that were shown in expt ip
	X = (single(imgs(:,:,istimN)) - 128) / 64;
	X = reshape(X, [], numel(find(istimN)));
	% normalize the pixels in each image
	X = normc(X);
	
	%% train the RF model on half the images
	rtrain = [1:ceil(size(X,2)/2)];
	% test the RF model on the other half of the images
	rtest = [ceil(size(X,2)/2)+1:size(X,2)];
	
	%% fit reduced-rank regression model
	lambda = 0.005;
	[a, b] = CanonCor2(V(rtrain,:), X(:,rtrain)', lambda);
	
	%% keep top 25 components of reduced rank regression model
	nc = 25;
	rfN = b(:, 1:nc) * a(:, 1:nc)';
	
	% prediction of neural activity from model
	Ypred = X' * rfN * C(:,1:nPC)';
	
	cRF = zscore(rfN * C(:,1:nPC)', 1, 1);
	cRF = reshape(cRF, Ly, Lx, NN);
	
	% how much variance the model explains
	R2train = 1 - nanmean(mean((Ypred(rtrain, :) - V(rtrain, :)*C(:,1:nPC)').^2, 1))./...
		nanmean(mean((V(rtrain, :)*C(:,1:nPC)').^2,1));
	R2test  = 1 - nanmean(mean((Ypred(rtest, :) - Y(rtest,:)).^2,1))./...
		nanmean(mean(Y(rtest,:).^2,1));
	%disp([R2train R2test])
	varexp = R2test;
	
	vtest = 1 - mean((Ypred(rtest, :) - Y(rtest,:)).^2,1)  ./ mean(Y(rtest,:).^2,1);
	
	% normalized variance explained
	rtest1 = respN(rtest,:,1);
	rtest2 = respN(rtest,:,2);
	rtest1 = rtest1 - b0;
	rtest2  = rtest2 - b0;
	vvtest1  = nanmean(rtest1.^2,1);
	res1   = rtest1 - Ypred(rtest,:);
	res2   = rtest2 - Ypred(rtest,:);
	vvr = 1 - nansum(nansum(res1.*res2,1))/nansum(nansum(rtest1.*rtest2,1));
	
	fprintf('natimg2800 low-rank RF varexp (normalized): %0.3f\n', mean(vvr));
	
	% plot best receptive fields
	[~,ibest] = sort(vtest, 'descend');
	clf;
	for j = 1:30
		my_subplot(10,3,j);
		imagesc(cRF(:,:,ibest((j-1)*10+5)),[-1 1]*8);
		axis image;
	end
	colormap(redblue)
	drawnow;
	
	% save RF model
	results.aAll{k}     = gather_try(a(:,1:nc));
	results.bAll{k}     = gather_try(b(:,1:nc));
	results.cAll{k}     = gather_try(C(:,1:nPC));
	results.veAll{k}    = gather_try(varexp);
	results.vtest{k}    = gather_try(vtest);
	results.vtestExp{k} = gather_try(vvr);
	
end
%%

save(fullfile(matroot, 'lowrank_fits.mat'), '-struct', 'results');




