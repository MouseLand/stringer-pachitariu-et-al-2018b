function incNeurEphysComparison(matroot)

%%
nstims = 2800;
nPCspont = 0;

clear specS;

load(fullfile(matroot,sprintf('%s_proc.mat','natimg2800')));

%%
clear specS;
ik=0;
K = 1;
specS = NaN * ones(700, 7);
alpha=[];
Nephys = 877;
nneur = [2.^[8:9] Nephys 2.^[11:13]];

for iexp = 1:7
	ik = ik+1;
	disp(ik)
	respBz = double(respAll{ik});
	
	sperm = randperm(size(respBz,1));
	nperm = randperm(size(respBz,2));
	sr0 = 700;
	
	respSub = respBz(1:sr0,:,:);
	
	clf;
	for k = 1:length(nneur)
		nn = nneur(k);
		if nn>size(respSub,2)
			nn = size(respSub,2);
		end
		nshuff = 10;
		ss = shuffledSpectrum(respSub(:,randperm(size(respSub,2),nn),:), nshuff);
		ss = nanmean(ss,2);
		ss = ss(:) / nansum(ss);
		loglog(ss);
		drawnow;
		if nneur(k)==Nephys
			specS(1:numel(ss), ik) = ss;
		end
		alpha(k,ik) = get_powerlaw(ss, [11:min(500,nneur(k)-2)]);
		disp(alpha(k,ik))
	end
end

save(fullfile(matroot, 'eigsControls_natimg2800_ephys.mat'),'alpha','specS','nneur','Nephys');

%% concatenate recordings
clear specS;
ik=0;
K = 1;
specS = NaN * ones(700, 7);
alpha=[];
nneur = [2.^[8:9] Nephys 2.^[11:13]];

A = [];
for j = 1:7
	resp0 = double(respAll{j});
	resps = NaN * zeros(2800, size(resp0,2), 2, 'double');
	resps(istimAll{j},:,:) = resp0;
	A = cat(2, A, resps);
end
iNotNaN = ~isnan(sum(A(:,:),2));
iNotNaN(end) = 0;

A = A(iNotNaN, :, :);

for it = 1:10
	for k = 1:length(nneur)
		sperm = randperm(size(A,1));
		nperm = randperm(size(A,2));
		sr0 = 700;
		
		respSub = A(1:sr0,:,:);
		
		nn = nneur(k);
		if nn>size(respSub,2)
			nn = size(respSub,2);
		end
		nshuff = 10;
		ss = shuffledSpectrum(respSub(:,randperm(size(respSub,2),nn),:), nshuff);
		ss = nanmean(ss,2);
		ss = ss(:) / sum(ss);
		if nneur(k)==Nephys
			specS(1:numel(ss), it) = ss;
		end
		alpha(k,it) = get_powerlaw(ss, [11:min(500,nneur(k)-2)]);
		clf;
		loglog(ss)
		drawnow;
		disp(alpha(k,it))
	end
end

%%

save(fullfile(matroot, 'eigsControls_natimg2800_ephys_concatenate.mat'),'alpha','specS','nneur','Nephys');

