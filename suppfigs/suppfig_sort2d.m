function suppfig_sort2d(matroot)

load(fullfile(matroot, 'natimg2800_proc.mat'));

%%
resp = respAll{6};
clear respAll;
%%
close all;
default_figure([1 1 6 8]);

%%
Ff = mean(resp,3)';
useGPU = 1;


S = zscore(Ff, 1, 2)/size(Ff,2).^.5;
[NN, NT] = size(S);

if useGPU
	S = gpuArray(single(S));
end

% the top PC is used to initialize the ordering
[U, Sv,V] = svdecon(S); % svdecon is contained in the repository
U1        = U(:,1);
V1        = V(:,1);
[~, isort] = sort(U1(:,1));
[~, isort2] = sort(V1(:,1));

iPC{1} = 1:2;
iPC{2} = 3:10;
iPC{3} = 11:40;
iPC{4} = 41:200;
iPC{5} = 201:1000;

nPCk = [10; 24; 64; 100; 200];

%%
clf;
for k = 1:5
	iPCs = iPC{k};
	
	nC = nPCk(k);
	
	dN = U(:,iPCs) * Sv(iPCs, iPCs);
	dT = Sv(iPCs, iPCs) * V(:,iPCs)';
	
	% run the embedding
	[iclustup, isort] = embed1D(dN, nC, isort); %
	[iclust2, isort2] = embed1D(dT', nC, isort2); %
	
	%  this cell plots the cells sorted by the ordering and smoothed over cells
	
	Sm = U(:,iPCs) * (U(:,iPCs)' * S);
	Sm = Sm(isort, isort2);
	
	if useGPU
		Sm = gpuArray(Sm);
	end
	
	sig_smooth = [8 2]; 
	Sm = my_conv2(Sm, sig_smooth, [1 2]);
	Ss = flipud(Sm');
	if k < 5
		my_subplot(4,1,k,[.8 .7]);
		imagesc(Ss, [-.2 .7]/125) % play with the scaling of the image too
		cmap = colormap('viridis');
		% colormap(flipud(cmap))

		set(gca, 'xtick', [2000:2000:10000])
		set(gca, 'ytick', [500:1000:3000])
		%set(gca, 'Fontsize', 14)
		title(sprintf('dimensions %d to %d', iPCs(1), iPCs(end)))

		xlabel('neurons (sorted)')
		ylabel('images (sorted)')
		text(-.1,1.1,char(96+k),'fontsize',14,'fontweight','bold');
		drawnow;
	end
	Sall{k} = gather(Sm);
end

%%
%save(fullfile(matroot, 'sortings_dset6.mat'),'Sall','iPC');

%%
print('../figs/supp_sorting.pdf','-dpdf')