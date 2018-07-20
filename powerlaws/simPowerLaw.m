% simulations to validate cross-validated PCA method
function simPowerLaw(matroot)

% use empirical noise spectrum
stimset={'natimg2800'};
load(fullfile(matroot,sprintf('%s_proc.mat',stimset{1})));
alpha=0.7;

%%
for k = 1:length(respAll)
	[ss0,cproj,ns0]=shuffledSpectrum(single(respAll{k}),10,useGPU);
	ns           = gather_try(nanmean(ns0,2));
	ns           = ns / sum(ns);
	specNoise{k} = ns;
	
	clf;
	loglog(ns);
	[a,ypred]=get_powerlaw(ns,[11:500]);
	title(a)
	hold all;
	plot(ypred,'k');
	drawnow;
	alpha(k)     = a;
	
end

mean(alpha)

%%

n  = 2800;
nn = 1e4;

nscale = [0 0.5 1 2; ...
          0 0.7 1.45 2.6; ...
          0 1.45 3 5.4];
nscale = nscale';
specSim = NaN*zeros(n,length(nscale),10);
Vx  = NaN*zeros(nn,length(nscale),10);
snr = NaN*zeros(nn,length(nscale),10);
R = gpuArray.randn(n, nn,'single');

nevals = [1:n].^-mean(alpha)/2;
nevals = nevals / sum(nevals);
nevals = gpuArray(single(nevals));

plaw = [.5 1.0160 1.5];
for ip = 1:length(plaw)
	
	evals = [1:n].^-(plaw(ip)/2);
	evals = evals / sum(evals);
	evals = gpuArray(single(evals));
	resp0 = diag(evals) * R;
	
	for in = 1:length(nscale)
		clf;
		if in == 1
			nit = 1;
		else
			nit = 10;
		end
		for it = 1:nit
			if in > 1
				R2 = gpuArray.randn(n, nn, 2,'single');
				noise = gpuArray.zeros(n,nn,2,'single');
				for j = 1:2
					noise(:,:,j) = diag(nevals) * R2(:,:,j);
				end
				
				resp = resp0 + nscale(in,ip) * noise;
				resp = permute(resp,[2 1 3]);
				resp = resp(:,:) - mean(resp(:,:),2);
				resp = permute(reshape(resp,nn,n,2),[2 1 3]);
				
				sigvar = diag(corr(gather_try(resp(:,:,1)),gather_try(resp(:,:,2))));
				sigvar = gather_try(sigvar);
								
				nshuff = 10;
				[ss0,cproj] = shuffledSpectrum(resp, nshuff, useGPU);
				ss = gather_try(nanmean(ss0,2));
				ss = ss(:) / sum(ss);
				
				vnoise = var(resp(:,:,1) - resp(:,:,2), 1, 1) / 2;
				v1     = var(resp(:,:,1), 1, 1);
				v2     = var(resp(:,:,2), 1, 1);
				sn     = (v1 + v2 - 2*vnoise) ./ (2*vnoise);
				sn     = gather_try(sn);
			else
				[u s v] = svdecon(resp0 - mean(resp0,1));
				ss = diag(gather_try(s)).^2;
				ss = ss(:) / sum(ss);
				sigvar = ones(nn,1,'single');
				sn     = Inf;
			end
			
			loglog(ss);
			[a,ypred]=get_powerlaw(ss,[11:500]);
			title([a nanmean(sn) nanmean(sigvar)]);
            disp([a nanmean(sn) nanmean(sigvar)]);
			hold all;
			drawnow;
			specSim(:,in,it,ip) = ss;
			Vx(:,in,it,ip) = sigvar;
			snr(:,in,it,ip) = sn;
		end
	end
end
%%
save(fullfile(matroot,'simSpectrum.mat'),'specSim','Vx','nscale','snr');

