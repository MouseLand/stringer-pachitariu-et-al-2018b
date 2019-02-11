% simulations to validate cross-validated PCA method
% simulate 2P noise by filtering with exponential and then adding noise and
% deconvolving signals

function simPowerLaw_deconv(matroot)

% need path to OASIS matlab package
addpath(genpath('/github/OASIS_matlab'));

%% use empirical noise spectrum

stimset={'natimg2800'};
load(fullfile(matroot,sprintf('%s_proc.mat',stimset{1})));

k = 3;
[ss0,cproj,ns0]=shuffledSpectrum(double(respAll{k}),10);
ns           = nanmean(ns0,2);
ns           = ns / sum(ns);

clf;
loglog(ns);
[a,ypred]=get_powerlaw(ns,[11:500]);
title(a)
hold all;
plot(ypred,'k');
drawnow;

nevals = ns.^2;
nevals = nevals / max(nevals);

%%

n  = 2800;
nn = 1e4;

specSim = NaN*zeros(n, 3, 10);
Vx  = NaN*zeros(nn, 3, 10);
snr = NaN*zeros(nn, 3,10);
alp = NaN*zeros(3, 10);

% have to use 2.5 Hz sampling
dt = 3; % 3 samples per stimulus
% response matrix
R = randn(n, nn, 'double');
[u,~,R] = svdecon(R);
u = permute(reshape(repmat(u, dt, 1), [n, dt, n]), [2, 1, 3, 4]);
u = reshape(u, [n*dt, n]);


% exponential kernel for convolving / deconvolving
fs = 2.5; % sampling rate in Hz
tsig = 2 * fs; % 2 sec decay
t = [0:1:60];
kexp = exp(-t / tsig);
g = exp(-1 / tsig);

plaws = [0.5 1.0 1.5];

nscale = [1 .94 .93];

%%
for ip = 1:3
	plaw = plaws(ip);
	evals = [1:n].^-(plaw/2);
	evals = evals / max(evals);
	
	% GT responses
	resp0 = u * diag(evals) * R';
	% responses are rectified
	resp0 = resp0 / std(resp0(:)) + 3;
	resp0 = max(0, resp0);
	
	% ground truth power law
	resp1 = repmat(resp0, 1, 1, 2);
	resp1 = squeeze(mean(reshape(resp1, [3, n, nn, 2]),1));
	resp1 = resp1 - mean(resp1,1);
	nshuff = 1;
	[ss0,cproj] = shuffledSpectrum(resp1, nshuff);
	ss = nanmean(ss0,2);
	ss = ss(:) / nansum(ss);
	[a,ypred]=get_powerlaw(ss,[11:500]);
	specSimGT(:, ip) = ss;
	alpGT(ip) = a;
	disp(a);
	
	%%
	for it = 1:10
		%%
		noise = zeros(n*dt, nn, 2, 'double');
		for j = 1:2
			[un,~,~] = svdecon(randn(n*dt, n, 'double'));
			noise(:,:,j) = un * diag(nevals) * R';
		end
		noise = noise / std(noise(:)) + 3;
		gain = exprnd(1, n, 1, 2);
		gain = permute(reshape(repmat(gain, dt, 1, 1), [n, dt, 1, 2]), [2, 1, 3, 4]);
		gain = reshape(gain, [n*dt, 1, 2]);
		
		resp1 = max(0, (resp0 + .18 * nscale(ip) * noise))...
			.* (0.5 + 0.8 * nscale(ip) * gain);
		
		
		%%
		% convolve, add gaussian noise
		resp_conv = filter(kexp/sum(kexp), 1, resp1, [], 1);
		resp_conv = resp_conv + 0.25 * randn(size(resp_conv), 'double');
		resp_conv = reshape(permute(resp_conv, [1, 3, 2]), [2*n*dt, nn]);
		
		%%
		% deconvolve
		sp = zeros(n*dt*2, nn, 'double');
		parfor k = 1:size(resp_conv,2)
			% nonnegative deconvolution (no sparsity constraints)
			[~,sp(:,k)] = oasisAR1(resp_conv(:,k)', g, 0);
		end
		
		sp = permute(reshape(sp,[n*dt, 2, nn]), [1, 3, 2]);
		resp1 = sp;
		
		% average over stimulus bins
		resp1 = squeeze(mean(reshape(resp1, [3, n, nn, 2]),1));
		resp1 = resp1 - mean(resp1,1);
		
		sigvar = mean(resp1(:,:,1) .* resp1(:,:,2),1) ./ ...
			(0.5 * (mean(resp1(:,:,1).^2,1) + mean(resp1(:,:,2).^2,1)));
		
		disp(nanmean(sigvar))
		
		%%
		nshuff = 10;
		[ss0,cproj] = shuffledSpectrum(resp1, nshuff);
		ss = nanmean(ss0,2);
		ss = ss(:) / nansum(ss);
		
		vnoise = var(resp1(:,:,1) - resp1(:,:,2), 1, 1) / 2;
		v1     = var(resp1(:,:,1), 1, 1);
		v2     = var(resp1(:,:,2), 1, 1);
		sn     = (v1 + v2 - 2*vnoise) ./ (2*vnoise);
		
		clf
		loglog(ss);
		[a,ypred]=get_powerlaw(ss,[11:500]);
		title([a nanmean(sigvar)]);
		disp([a nanmean(sigvar)]);
		hold all;
		drawnow;
		specSim(:, ip, it) = ss;
		Vx(:, ip, it) = sigvar;
		snr(:,ip, it) = sn;
		alp(ip, it) = a;
	end
end

%%
save(fullfile(matroot,'simSpectrum_add_gain_deconv.mat'),'specSim','Vx','nscale','snr','alp', 'specSimGT', 'alpGT');

%%
