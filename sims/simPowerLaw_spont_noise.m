% simulations to validate cross-validated PCA method
% simulate 2P noise by filtering with exponential and then adding noise and
% deconvolving signals

function simPowerLaw_spont_noise(matroot)

%%
alpha=0.74;

n  = 2800;
nn = 1e4;

nscale = 2;

gscale = [0 .1 1 10];

specSim = NaN*zeros(n, 4, 4, 10);
Vx  = NaN*zeros(nn, 4, 4, 10);
snr = NaN*zeros(nn, 4, 4, 10);
alp = NaN*zeros(4, 4, 10);
%R = poissrnd(2, n, nn);
R = gpuArray.randn(n, nn, 'single');

nevals = [1:n].^(-1.14/2);
nevals = nevals / max(nevals);
nevals = gpuArray(single(nevals));

plaw = 1.50;
evals = [1:n].^-(plaw/2);
evals = evals / max(evals);
evals = gpuArray(single(evals));
[u,~,R] = svdecon(R);
resp0 = u * diag(evals) * R';
resp0 = resp0 / std(resp0(:)) + 3;
orthnoise = gpuArray.randn(n, nn, 'single');
[un, ~, Rn] = svdecon(orthnoise); 

%u0 = u * diag(evals);
%u0 = u0/std(u0(:));
%%
t = [1:100];

clf;
gscale = [6.5 1.4 1.3 3.5; 1. 1. 1. 1.; .18 .5 .5 .3; 0 0 0 0];
for in = 3%2:size(gscale,1)
	if in == size(gscale,1)
		nit = 1;
	else
		nit = 3;
	end
	for it = 1:nit		
		if nit > 1
			for mult = 4
				if mult==1
					gain = gpuArray(single(exprnd(1, n, 1, 2)));
					resp1 = max(0, resp0 .* (1 + 3.5 * gscale(in,mult) * gain));
				elseif mult==2
					for j = 1:2
						[uu,~,~] = svdecon(gpuArray.randn(n, n, 'single'));
						orthnoise(:,:,j) = uu * diag(nevals) * Rn';%(Rn - Rn*resp0*resp0')';
						orthnoise(:,:,j) = orthnoise(:,:,j)  - orthnoise(:,:,j) * resp0' * resp0;
					end
					orthnoise = orthnoise / std(orthnoise(:)) + 3;
					resp1 = max(0, resp0 + 2.4 * gscale(in,mult) * orthnoise);
				elseif mult==3
					noise = gpuArray(single(exprnd(1, n, nn, 2))); % additive
					resp1 = max(0, resp0 + 2.5 * gscale(in,mult) * noise);
				else
					gain = gpuArray(single(exprnd(1, n, 1, 2)));
					for j = 1:2
						[uu,~,~] = svdecon(gpuArray.randn(n, n, 'single'));
						orthnoise(:,:,j) = uu * diag(nevals) * Rn';%(Rn - Rn*resp0*resp0')';
						orthnoise(:,:,j) = orthnoise(:,:,j)  - orthnoise(:,:,j) * resp0' * resp0;
					end
					orthnoise = orthnoise / std(orthnoise(:)) + 3;
					noise = gpuArray(single(exprnd(1, n, nn, 2))); % additive
					resp1 = max(0, resp0 .* (1 + 2.5 * gscale(in,1) * gain) + ...
								3.6 * gscale(in,4) * orthnoise + 0.8 * gscale(in,4) * noise);
				end
				resp1 = resp1 - mean(resp1,1);
				sigvar = mean(resp1(:,:,1) .* resp1(:,:,2),1) ./ ...
					(0.5 * (mean(resp1(:,:,1).^2,1) + mean(resp1(:,:,2).^2,1)));
				sigvar = gather_try(sigvar);

				nshuff = 5;
				[ss0,cproj] = shuffledSpectrum(resp1, nshuff, useGPU);
				ss = gather_try(nanmean(ss0,2));
				ss = ss(:) / nansum(ss);

				vnoise = var(resp1(:,:,1) - resp1(:,:,2), 1, 1) / 2;
				v1     = var(resp1(:,:,1), 1, 1);
				v2     = var(resp1(:,:,2), 1, 1);
				sn     = (v1 + v2 - 2*vnoise) ./ (2*vnoise);
				sn     = gather_try(sn);
				clf
				loglog(ss);
				[a,ypred]=get_powerlaw(ss,[11:500]);
				title([a nanmean(sigvar)]);
				disp([a nanmean(sigvar)]);
				hold all;
				drawnow;
				specSim(:, in, mult, it) = ss;
				Vx(:, in, mult, it) = sigvar;
				snr(:, in, mult, it) = sn;
				alp(in, mult, it) = a;
			end
		
		else
			resp1 = repmat(resp0, 1, 1, 2);
			nshuff = 1;
			[ss0,cproj] = shuffledSpectrum(resp1, nshuff, useGPU);
			ss = gather_try(nanmean(ss0,2));
			ss = ss(:) / nansum(ss);
			clf
			loglog(ss);
			[a,ypred]=get_powerlaw(ss,[11:500]);
			title([a]);
			disp([a]);
			hold all;
			drawnow;
			specSim(:, in, mult, it) = ss;
			Vx(:, in, mult, it) = sigvar;
			snr(:, in, mult, it) = sn;
			alp(in, mult, it) = a;
		
		end
	end
end
%%
save(fullfile(matroot,'simSpectrum_withmult.mat'),'specSim','Vx','nscale','snr','alp');

