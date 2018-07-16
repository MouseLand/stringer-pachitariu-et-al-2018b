%% load images from all stim types
clear all;

stimtype = {'natimg','white','8D','4D','small','ori','sparse'};
clear imgs;

imgs = loadImages(stimtype, 2);

%imgs(3:7) = imgs(2:6);
%imgs{2} = imgs{1};
[Ly,Lx,nimg] = size(imgs{1});

matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';

%% Gabors from data
results = load(fullfile(matroot,'gaborFits.mat'));

%%

dset   = 6;
bestGB = results.bestGB{dset};
A = results.rfstats{dset}(1:end-1,:);
vtest   = results.vtest{dset};
NN = numel(results.vtest{dset});
cbest = results.bestC{dset};
bmax  = cbest(:,3:4);
cmax  = cbest(:,1:2);

X = gpuArray(single(results.X));


% compute center-surround at position yp(iy), xp(ix)
fg1   = gaborReduced(A,X);
A2    = A;
A2(5,:) = A2(5,:) + pi/2;
fg2   = gaborReduced(A, X);
	
clf;
clear respG1 respG2;
for K = 1:numel(imgs)
	
	img0 = reshape(imgs{K}, [], size(imgs{K},3));
	
	respG1 = fg1' * img0;
	respG2 = fg2' * img0;
	respG2 = (respG1.^2 + respG2.^2).^.5;
	respG1 = max(0, respG1);
	respG2 = max(0, respG2);
	tpred  = cmax(:,1).*(respG1 - bmax(:,1)) + ...
		cmax(:,2).*(respG2 - bmax(:,2));
	tpred = gather(tpred);        
	        
	tpred = tpred(vtest>.05,:);
	
	[u s v] = svdecon(tpred - mean(tpred,2));
	s = gather(s);
	s = diag(s).^2;
	
	trange0 =  [10:min(500,numel(s)-1)];
	[a,ypred,~,r] = get_powerlaw(s,trange0);
	
	subplot(3,numel(imgs),K),
	loglog(s/sum(s));
	hold all;
	loglog(ypred/sum(s));
	title([a r]);
	drawnow;
	alpha(K) = a;
	
	specA{K} = s / sum(s);
	predA{K} = ypred / sum(s);
	
end

%%

save(fullfile(matroot,'gaborCSfits2natimg.mat'),'specA','alpha');
