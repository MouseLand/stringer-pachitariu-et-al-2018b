function fig1(dataroot, matroot)

load(fullfile(dataroot,'images_natimg2800_all.mat'));
load(fullfile(matroot,'natimg2800_proc.mat'));

load(fullfile(matroot,'eigs_and_stats_all.mat'));
load(fullfile(matroot,'natimg32_reps.mat'));
load(fullfile(matroot, 'decoder2800.mat'));

lr = load(fullfile(matroot,'lowrank_fits.mat'));
gb = load(fullfile(matroot,'gabor_fits.mat'));

%% dataset colors
col = colormap('parula');
col = col(round(linspace(1,60, size(pCorrect,2))), :);
rng(3);
icol = randperm(size(pCorrect,2));

%% choose example dataset and compute RFs for plot
d = 5;
[~, isort] = sort(lr.vtest{d}, 'descend');
[Ly,Lx,~]=size(imgs);
% low-rank RFs
[lrRF] = plotLowRankRFs(Ly, Lx, lr.aAll{d}, lr.bAll{d}, lr.cAll{d});
NN = numel(isort);
% gabor RFs
[gbRF] = plotGaborRFs(Ly, Lx, gb.rfstats{d});
cgb = gb.rfstats{d}(end,:);

%%
close all;
xf = 4.5;
yf = 7;
HF=default_figure([11 3 xf yf]);

clf;
i=0;
i=i+1;

xh = .65;
yh = xh;
% ------- RECORDING SETUP
hs{i}=my_subplot(8,4,1,[xh yh]);
axis off;
hp=hs{i}.Position;
axes('position',[hp(1)-.03 hp(2)-.03 1.4*hp(3:4)]);
im = imread('fig/planes.PNG');
imagesc(im);
axis off;
axis image;

% --------- EXAMPLE PLANE ---------------------------------------------
i=i+1;
hs{i}=my_subplot(8,4,2,[xh yh]);
axis off;
hp=hs{i}.Position;
axes('position',[hp(1)-.02 hp(2)-.03 1.15*hp(3:4)]);
im = imread('fig/explane.PNG');
imagesc(im);
title('plane 5/11','fontweight','normal','fontsize',8);
axis off;
axis image;

% ---- PLOT EXAMPLE IMAGE ---------------------------------------------
i=i+1;
hs{i} = my_subplot(8,2,3,[.72 .72]);
hs{i}.Position(2) = hs{i}.Position(2) - .05;
img = imgs(:,:,1);
imagesc(img)
colormap('gray');
hold all;
plot(  90 * [1 1], [1 Ly], 'k');
plot( 180 * [1 1], [1 Ly], 'k');
colormap(hs{i},'gray');
axis image;
[Ly, Lx, nchan] = size(img);
set(gca, 'xtick', [1/6 3/6 5/6] * Lx, 'xticklabel', [-90, 0, 90])
set(gca, 'ytick', [1 3 5]/6 * Ly, 'yticklabel', [30, 0, -30])
xlabel('horizontal angle', 'Fontsize', 8)
ylabel({'vertical angle'}, 'Fontsize', 8)


% ------ TRIAL-AVERAGED DATA ---------------------------------------------
i=i+1;
hs{i} = my_subplot(4,4,9,[.7 .9]);
hs{i}.Position(1) = hs{i}.Position(1)+.01;
hs{i}.Position(2) = hs{i}.Position(2)+.13;
rng(11);
R32 = dat32{4};
iperm = randperm(size(R32,2), 65);
R32 = zscore(R32(1:32, iperm,:),1,1);
% FIRST REPEAT
imagesc(R32(:, :,1)', [-5 5])
text(-.01, .5, sprintf('neurons   65 / %d',size(dat32{3},2)),  'Rotation', 90, 'horizontalalign', 'center', 'verticalalign', 'bottom', 'Fontangle', 'normal', 'fontsize', 8)
text(.5, -.02, 'stimuli', 'horizontalalign', 'center', 'verticalalign', 'top', 'Fontangle', 'normal', 'fontsize', 8)
axis off
axis image;
rb = redblue;
colormap(hs{i},rb)
text(.0, 1.0, 'first data half', 'verticalalignment', 'bottom','HorizontalAlignment','left','fontsize',8)
% SECOND REPEAT
hp = my_subplot(4,4,10,[.7 .9]);
hp.Position(2) = hp.Position(2)+.13;
hp.Position(1) = hp.Position(1)-.05;
imagesc(R32(:, :,2)', [-5 5])
text(.5, -.02, 'stimuli', 'horizontalalign', 'center', 'verticalalign', 'top', 'Fontangle', 'normal', 'fontsize', 8)
axis off
text(.0, 1.0, 'second data half', 'verticalalignment', 'bottom','HorizontalAlignment','left','fontsize',8)
axis image;
colormap(hp,rb)
hc=colorbar;
hc.Position(1)=.44;
hc.Position(2)=hp.Position(2);
hc.Position(4) = .04;

% ------- STIMULUS ORDER ---------------------------------------------
i=i+1;
hs{i} = my_subplot(8,2,5,[.6 .6]);
hs{i}.Position(2) = hs{i}.Position(2) - .41;
load(fullfile(dataroot,'default_stim_order.mat'))
img = [];
L   = size(imgs,1);
%istim = stim.istim;
istim(istim>2800) = [];
for j = 1:6
	img = cat(2, img, imgs(:,1:90, j*8), 2000 * ones(L, ceil(L/10)));
end
img = cat(2, img, imgs(:,1:90), 2000 * ones(L, 4*L));
img = cat(1, img, 2000*ones(ceil(L/2), size(img,2)), img);
imagesc(img)
colormap(hs{i},'gray');
text(-.02, .85, 'repeat 1', 'horizontalalignment', 'right', 'verticalalignment', 'middle', 'Fontsize', 8, 'Fontangle', 'normal');
text(-.02, .25, 'repeat 2', 'horizontalalignment', 'right', 'verticalalignment', 'middle', 'Fontsize', 8, 'Fontangle', 'normal');
axis off
text(.72, .85, '... ', 'horizontalalignment', 'left', 'verticalalignment', 'middle', 'Fontsize', 16, 'Fontweight', 'bold', 'Fontangle', 'normal');
text(.72, .25, '... ', 'horizontalalignment', 'left', 'verticalalignment', 'middle', 'Fontsize', 16, 'Fontweight', 'bold', 'Fontangle', 'normal');
text(.85, .85, 'x2800', 'horizontalalignment', 'left', 'verticalalignment', 'middle', 'Fontsize', 8, 'Fontweight', 'bold', 'Fontangle', 'normal');
text(.85, .25, 'x2800', 'horizontalalignment', 'left', 'verticalalignment', 'middle', 'Fontsize', 8, 'Fontweight', 'bold', 'Fontangle', 'normal');


% -------- SNR ----------------------------------------------------------------
i=i+1;
hs{i} = my_subplot(8,2,15,[.65 1]);
hs{i}.Position(2) = hs{i}.Position(2) + .06;
hs{i}.Position(1) = hs{i}.Position(1) + .01;

for k = 1:numel(snr{1})
	histogram(snr{1}{k}, linspace(-.05,0.6, 100), 'EdgeColor', col(icol(k), :), 'DisplayStyle', 'stairs', 'Linewidth', 1)
	hold on
	plot(nanmean(snr{1}{k}), 700,'v','color',col(icol(k),:));
end
axis tight;
box off;
ylabel('number of cells');
xlabel('tuning SNR');
ncells = sum(cellfun(@(x) numel(x), snr{1}));
for k = 1:numel(snr{1})
	if k == 1
		text(.6, 1.1 - .1*k, sprintf('N = %d neurons', numel(snr{1}{k})),...
			'Color', col(icol(k),:), 'Fontangle', 'normal', 'Fontsize', 6);
	else
		text(.6, 1.1 - .1*k, sprintf('N = %d', numel(snr{1}{k})),...
			'Color', col(icol(k),:), 'Fontangle', 'normal', 'Fontsize', 6);
	end
end

% ------ DECODING AS A FUNCTION OF NEURONS -------------------------------------
i=i+1;
hs{i} = my_subplot(4,2,2,[.6 .6]);
hs{i}.Position(2) = hs{i}.Position(2) -.005;
for k = 1:size(pCorrect,2)
	loglog(nNeu(:,k), pCorrect(:,k), 'Color', col(icol(k), :), 'Linewidth', 1);
	hold all
end
plot([1 10^4.15], [1/2800 1/2800], '-k', 'Linewidth', 1)
text(1, .28, 'chance level', 'Horizontalalign', 'right','fontsize',8)
box off
axis tight
xlabel('number of neurons')
ylabel('fraction correct')
set(gca, 'xtick', 10.^[1 2 3 4], 'ytick', 10.^[-4:0])
ylim(10.^[-4 0])
axis square
grid on;
grid minor;
grid minor;



% ------------------------ RFS -------------------------------------------
rng(12);
nsp = 100;
ineu = [isort(2:14)'];
for ii = 1:2
	for j = 1:size(ineu,1)
		h2=my_subplot(24,4,(j-1)*4+(ii-1)+4*7+3,[.65 .73]);
		h2.Position(2) = h2.Position(2) - .01;
		if ii==2
			h2.Position(1) = h2.Position(1)-.02;
		end
		if k ==2
			h2.Position(2) = h2.Position(2)+.035;
		end
		if ii==1 && j==1
			i=i+1;
			hs{i}=h2;
		end
		if ii == 1
			A = lrRF(:,:,ineu(j));
			A = A /std(A(:));
		else
			A = gbRF(:,:,ineu(j));
			A = A / std(A(:));
		end
		imagesc(A(:,:), [-1 1]*7)
		hold all;
		colormap(h2,rb)
		axis off;
		if j==1
			if ii==1
				text(.5, 1.1, 'linear RF model', 'verticalalignment', 'bottom', 'horizontalalignment', 'center','fontsize',8)
				hc=colorbar;
				hc.Position(1) = .73;
				hc.Position(2) = h2.Position(2)+.0;
				hc.Position(4) = .04;
			else
				text(.5, 1.1, {'Gabor model'}, 'verticalalignment', 'bottom', 'horizontalalignment', 'center','fontsize',8)
			end
		end
	end
end


% ---------- AVG RF ---------------------------------------
i=i+1;
hs{i} = my_subplot(8,2,16,[.72 .72]);
hs{i}.Position(2) = hs{i}.Position(2) + .01;
hs{i}.Position(1) = hs{i}.Position(1) -.01;
for d = 1:numel(gb.vtest)
	ineu = gb.vtest{d} > .05;
	y=gb.rfstats{d}(6,ineu)' - 34;
	x=gb.rfstats{d}(7,ineu)' - 135;
	xneg = mean(x) - prctile(x,5);
	xpos = prctile(x,95) - mean(x);
	yneg = mean(y) - prctile(y,5);
	ypos = prctile(y,95) - mean(y);
	errorbar(mean(x),mean(y),yneg,ypos,xneg,xpos,'color',col(icol(d), :))
	hold all;
end
ylabel('vertical angle')
xlabel('horizontal angle')
axis image;
axis([-135 135 -67/2 67/2]);
set(gca,'ytick',[-30 30],'xtick',[-90 0 90]);
hold all;
plot(-45*[1 1], [-45 45],'k');
plot(45*[1 1], [-45 45],'k');

% ------------ TITLES AND LETTERS ----------------------------------
ttl{1} = '';ttl{2} = '';
ttl{3} = 'Example stimulus';
ttl{5} = 'Stimulus sequence';
ttl{4} = 'Example data (trial-averaged)';
ttl{6} = 'Neural stimulus tuning';
ttl{7} = 'Decoding 2800 stimuli';
ttl{8} = 'Best single-neuron RFs';
ttl{9} = 'RF locations';
for j = 1:length(hs)
	hp=hs{j}.Position;
	if j==1 || (j>2 && j<7)
		hp(1) = .01;
		hp(2) = hp(2) + hp(3)*.12;
		if j==4
			hp(2) = hp(2) + hp(3)*.2;
		end
	elseif j==8
		hp(1) = hp(1)-.06;
		hp(2) = hp(2)+.05;
	elseif j==7
		hp(1) = hp(1)-.11;
		hp(2) = hp(2)+.04;
	elseif j==9
		hp(1) = hp(1)-.08;
		hp(2) = hp(2)+.03;
	else
		hp(1)=hp(1)-.03;
		hp(2)=hp(2)+.018;
	end
	axes('position',hp);
	axis off;
	%if j ==2
	%    jy = 1.65 ;
	%    jx = -.5;
	%else
	jy = 1;
	jx = 0;
	%end
	text(jx,jy,char(96+j),'units','normalized','fontsize',11,'fontweight','bold','fontangle','normal');
	hp(1)=hp(1)+.03;
	axes('position',hp);
	axis off;
	text(0,.98,ttl{j},'units','normalized','fontsize',10,'fontangle','normal');
	
end

print(fullfile(matroot,'fig1.pdf'),'-dpdf');