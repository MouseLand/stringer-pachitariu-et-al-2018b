%%% concatenate recordings with similar RFs and compute powerlaw
function concatenateRecordings(matroot)

%%
gb = load(fullfile(matroot,'gabor_fits.mat'));
xy = cellfun(@(x) nanmean(x(6:7, :), 2), gb.rfstats, 'UniformOutput', 0);
xy = cell2mat(xy);
% ^ use these RF centers to concatenate recordings
% (The only central RFs are concatenated even though they aren't that close to each other)
% the pairs are DIFFERENT mice
ipairs = {[1 4], [2 3], [5 7]};

%% load natimg2800 responses
stimset={'natimg2800'};
load(fullfile(matroot,sprintf('%s_proc.mat',stimset{1})));
%%
alp = [];
for k = 1:length(ipairs)
	A = [];
	for j = 1:length(ipairs{k})
		resp0 = double(respAll{ipairs{k}(j)});
		resps = NaN * zeros(2800, size(resp0,2), 2, 'double');
		resps(istimAll{ipairs{k}(j)},:,:) = resp0;
		A = cat(2, A, resps);
	end
	iNotNaN = ~isnan(sum(A(:,:),2));
	iNotNaN(end) = 0;
	
	A = A(iNotNaN, :, :);
	
	nshuff = 10;
	
	nperm = randperm(size(A,2));
	nr      = ceil(numel(nperm) * 2.^[0:-1:-7]);
        
	clf
	numNeu(k) = size(A,2);

	for n = 1:length(nr)
		[ss0,cproj] = shuffledSpectrum(A(:, nperm(1:nr(n)), :), nshuff);
		ss = nanmean(ss0,2);
		ss = ss(:) / nansum(ss);
	
		loglog(ss);
		[a,ypred]=get_powerlaw(ss,[11:500]);
		title([a]);
		disp([a]);
		hold all;
		%loglog(ypred)
		drawnow;
	
		specS{k}{n} = ss;
		yfit{k}{n} = ypred;
		alp(k,n) = a;
	
		avgRF{k} = xy(:,ipairs{k});
	end
end
%

save(fullfile(matroot,'combinedSessions.mat'), 'specS', 'yfit', 'alp', 'avgRF', 'ipairs', 'nr', 'numNeu');