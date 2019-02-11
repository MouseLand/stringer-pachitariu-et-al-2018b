% simulations to validate cross-validated PCA method
% poisson noise - simulate 2P noise
% multiplicative noise

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

nscale = [0 7.8 16 28; ...
	0 2.2 4.35 7.8; ...
	0 1.1 2.3 4];
nscale = nscale';

nscale_mult = [0 13 30 50; ...
	0 4.5 11 18; ...
	0 2.75 6 11];
nscale_mult = nscale_mult';

plaw = [.5 1.0160 1.5];

specSim = NaN*zeros(n,length(nscale),length(plaw),2,10);
Vx  = NaN*zeros(nn,length(nscale),length(plaw),2,10);
snr = NaN*zeros(nn,length(nscale),length(plaw),2,10);
alp = NaN*zeros(length(nscale),length(plaw),2,10);
R = gpuArray.randn(n, nn,'single');

nevals = [1:n].^-mean(alpha/2);
nevals = nevals / max(nevals);
nevals = gpuArray(single(nevals));

for ip = 1:length(plaw)
	
	evals = [1:n].^-(plaw(ip)/2);
	evals = evals / max(evals);
	evals = gpuArray(single(evals));
	resp0 = repmat(diag(evals) * R, 1, 1, 2);
	clf;
	for in = 1:length(nscale)
		clf;
		if in == 1
			nit = 1;
		else
			nit = 10;
		end
		for it = 1:nit
			%%
			R2 = gpuArray.randn(n, nn, 2,'single');
			noise = gpuArray.zeros(n,nn,2,'single');
			for j = 1:2
				noise(:,:,j) = diag(nevals) * R2(:,:,j);
			end
			for mm = 1:2
				if in > 1
					if mm == 1
						resp = resp0 + nscale(in,ip) * noise;
					else
						resp = resp0 .* (1 + nscale_mult(in,ip) * noise);
					end
					resp = permute(resp,[2 1 3]);
					resp = resp(:,:) - mean(resp(:,:),2);
					resp = permute(reshape(resp,nn,n,2),[2 1 3]);
					
					sigvar = mean(resp(:,:,1) .* resp(:,:,2),1) ./ ...
						      (0.5 * (mean(resp(:,:,1).^2,1) + mean(resp(:,:,2).^2,1)));
					%sigvar = diag(corr(gather_try(resp(:,:,1)),gather_try(resp(:,:,2))));
					sigvar = gather_try(sigvar);
					
					nshuff = 5;
					[ss0,cproj] = shuffledSpectrum(resp, nshuff, useGPU);
					ss = gather_try(nanmean(ss0,2));
					ss = ss(:) / sum(ss);
					
					vnoise = var(resp(:,:,1) - resp(:,:,2), 1, 1) / 2;
					v1     = var(resp(:,:,1), 1, 1);
					v2     = var(resp(:,:,2), 1, 1);
					sn     = (v1 + v2 - 2*vnoise) ./ (2*vnoise);
					sn     = gather_try(sn);
				else
					[u s v] = svdecon(resp0(:,:,1) - mean(resp0(:,:,1),1));
					ss = diag(gather_try(s)).^2;
					ss = ss(:) / sum(ss);
					sigvar = ones(nn,1,'single');
					sn     = Inf;
				end
				
				%%
				loglog(ss);
				[a,ypred]=get_powerlaw(ss,[11:500]);
				title([a nanmean(sn) nanmean(sigvar)]);
				disp([a nanmean(sn) nanmean(sigvar)]);
				hold all;
				drawnow;
				specSim(:, in, ip, mm, it) = ss;
				Vx(:, in, ip, mm, it) = sigvar;
				snr(:, in, ip, mm, it) = sn;
				alp(in, ip, mm, it) = a;
			end
		end
	end
end
%%
save(fullfile(matroot,'simSpectrum_withmult.mat'),'specSim','Vx','nscale','snr','alp');

