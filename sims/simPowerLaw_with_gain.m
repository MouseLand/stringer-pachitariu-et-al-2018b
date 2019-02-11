% simulations to validate cross-validated PCA method
% simulate 2P noise by filtering with exponential and then adding noise and
% deconvolving signals

function simPowerLaw_with_gain(matroot)

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

%%
nevals = ns.^0.5;
nevals = nevals / max(nevals);

%%

n  = 2800;
nn = 1e4;

specSim = NaN*zeros(n, 3, 3, 10);
Vx  = NaN*zeros(nn, 3, 3, 10);
snr = NaN*zeros(nn, 3, 3, 10);
alp = NaN*zeros(3, 3, 10);

specSimPCA = NaN*zeros(n, 3, 10);
alpPCA = NaN*zeros(3, 10);

% response matrix
R = randn(n, nn, 'double');
[u,~,R] = svdecon(R);

plaws = [.5 1.0 1.5];
nscale = [1 1; .97 1; .94 .9];

%%
for ip = 1:3
	
	plaw = plaws(ip);
	evals = [1:n].^-(plaw/2);
	evals = evals / max(evals);
	
	resp0 = u * diag(evals) * R';
	% responses are rectified
	resp0 = resp0 / std(resp0(:)) + 3;
	resp0 = max(0, resp0);
	
	%%
	for in = 1:2
		if in==1
			for it = 1:10
				for mult = 1:3
					if mult==1
						noise =zeros(n, nn, 2, 'double');
						for j = 1:2
							[un,~,~] = svdecon(randn(n, n, 'double'));
							noise(:,:,j) = un * diag(nevals) * R';
						end
						noise = noise / std(noise(:)) + 3;
						resp1 = max(0, resp0 + 2.45 * nscale(ip, mult) * noise);
					elseif mult==2
						gain = exprnd(1, n, 1, 2);
						resp1 = resp0 .* (0.5 + 1.7 * nscale(ip, mult) * gain);
					else
						resp1 = max(0, (resp0 + 0.25 * nscale(ip, 1) * noise))...
							.* (0.5 + 0.7 * nscale(ip, 2) * gain);
					end
					
					resp1 = resp1 - mean(resp1,1);
					sigvar = mean(resp1(:,:,1) .* resp1(:,:,2),1) ./ ...
						(0.5 * (mean(resp1(:,:,1).^2,1) + mean(resp1(:,:,2).^2,1)));
					
					nshuff = 10;
					[ss0,cproj,ns0] = shuffledSpectrum(resp1, nshuff);
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
					specSim(:, ip, mult, it) = ss;
					Vx(:, ip, mult, it) = sigvar;
					snr(:, ip, mult, it) = sn;
					alp(ip, mult, it) = a;
					
					% also compute PCA
					if mult==3
						% PCA
						rsp=mean(resp1,3);
						rsp = rsp - mean(rsp,1);
						[~,ss,~] = svdecon(rsp * rsp');
						ss = diag(ss);
						ss = ss(:) / nansum(ss(1:end-1));
						loglog(ss);
						[a,ypred]=get_powerlaw(ss,[11:500]);
						drawnow;
						specSimPCA(:,ip,it) = ss;
						alpPCA(ip,it) = a;
					end
				end
			end
		else
			resp1 = repmat(resp0, 1, 1, 2);
			resp1 = resp1 - mean(resp1,1);
			nshuff = 1;
			[ss0,cproj] = shuffledSpectrum(resp1, nshuff);
			ss = nanmean(ss0,2);
			ss = ss(:) / nansum(ss);
			clf
			loglog(ss);
			[a,ypred]=get_powerlaw(ss,[11:500]);
			title([a]);
			disp([a]);
			hold all;
			drawnow;
			specSimGT(:, ip) = ss;
			alpGT(ip) = a;
		end
	end
end
	%%
save(fullfile(matroot,'simSpectrum_add_gain.mat'),'specSim','Vx','nscale','snr','alp', 'specSimGT', 'alpGT','specSimPCA','alpPCA');
	
%%
% clf;
% nse = nanmean(ns0,2);
% %nse = nse/max(nse);
% %ns = ns/max(ns);
% [un,svn,vn] = svdecon(noise(:,:,1)-mean(noise(:,:,1),1));
% nsgt = diag(2.5*svn).^2;
% subplot(1,2,1),
% loglog(nsgt);
% hold all;
% loglog(nse,'r')
% axis square;
% axis tight
% 
% subplot(1,2,2),
% plot(nsgt,nse,'r.')
% hold all;
% plot(nsgt,nsgt,'k')
% xlabel('noise variance from data')
% ylabel('noise variance recovered from sim')
% axis tight
% axis square
% 
% 
