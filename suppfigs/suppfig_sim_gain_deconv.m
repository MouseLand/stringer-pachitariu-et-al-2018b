% simulate random data with power-law eigenspectra and evaluate
% cross-validated PCA analysis
function suppfig_sim_gain_deconv(matroot)

gs = load(fullfile(matroot,'simSpectrum_add_gain.mat'));
dc = load(fullfile(matroot,'simSpectrum_add_gain_deconv.mat'));
load(fullfile(matroot,'noiseSpectrum.mat'));
specSimPCA = gs.specSimPCA;
specSimGT = gs.specSimGT;

%%
close all;
default_figure([1 1 6 7]);
%%
xh = .55;
yh = .55;
clf;
i=0;
clear hs;
% dataset colors
col = colormap('parula');
col = col(round(linspace(1,60, 7)), :);

icomp = [5 10 100 1000];
for k = 1:4
	
	hp = my_subplot(4,6,k);
	hp.Position(1) = hp.Position(1)+.06;
	if k==1
		i=i+1;
		hs{i}=hp;
	end
	
	cp1 = cprojEx(:,icomp(k),1);
	cp2 = cprojEx(:,icomp(k),2);
	cp1 = cp1 - mean(cp1);
	cp2 = cp2 - mean(cp2);
	plot(cp1, cp2, '.', 'Markersize', 1)
	if k==1
		mx = .75 * max([cp1; cp2]);
		%text(-.5, 1.35, 'e', 'Fontweight', 'bold', 'Fontangle', 'normal', 'Units', 'normalized', 'verticalAlignment', 'top', 'Fontsize', 12);
	end
	box off
	
	xlim([-mx mx])
	ylim([-mx mx])
	
	text(0.5, 1.4, sprintf('PC %d', icomp(k)), 'horizontalalignment', 'center','Fontsize', 8)
	text(.05,  1.2, sprintf('r = %2.2f', corr(cp1,cp2)),'Fontsize', 8, 'Fontangle','normal')
	text(.05,  1, 'p < 10^{-15}','Fontsize', 6, 'Fontangle','normal')
	
	if k==1
		xlabel('comp {train}')
		ylabel('comp {test}')
	else
		set(gca, 'ytick', [])
		set(gca, 'xtick', [])
	end
	axis square;
end

i=i+1;
hs{i} = my_subplot(4,5,5,[.7,.7]);
hs{i}.Position(1) = hs{i}.Position(1) - .02;
for k = 1:7
	loglog(specNoise{k}, 'color',col(k,:))
	hold all;
	[alpNoise(k),~] = get_powerlaw(specNoise{k}, 11:500);
end
%text(.2,.8,sprintf('\\alpha=%1.2f \\pm %1.2f', mean(alpNoise), std(alpNoise)/sqrt(6)),...
%	'fontweight','bold','fontsize',8);
title('noise variance', 'fontweight','normal','fontsize',10);
box off;
grid on;
grid minor;
grid minor;
xlabel('signal PC dimensions');
ylabel('variance');
axis square;
axis([1 2800 1e-5 1]);
set(gca,'ytick',10.^[-6:1:0],'xtick',10.^[0:3]);




cm = colormap('lines');
%cm = cm(10:16:end,:);
ip0 = 8;
tstr = {'additive noise', 'gain modulation', 'additive + gain',...
	{'additive + gain','+ 2P noise'}};
for k = 1:4
	i=i+1;
	hs{i}=my_subplot(4,4,k+(k>2)*2+4,[xh yh]);
	hs{i}.Position(1) = hs{i}.Position(1) + .01;
	hs{i}.Position(2) = hs{i}.Position(2) - .02 + .03*(k>2);
	if k<4
		ss = gs.specSim(:, 2, k, ip0);
	else
		ss = dc.specSim(:, 2, ip0);
	end
	loglog(ss / sum(ss),'color',cm(k,:), 'linewidth',2);
	[a,ypred]=get_powerlaw(ss,[11:500]);
	hold all;
	loglog(ypred,'k');
	text(.45, .8, sprintf('\\alpha=%2.2f', a),'fontsize',8,...
		'fontweight','bold')
	
	box off;
	grid on;
	grid minor;
	grid minor;
	if k==1
		xlabel('dimensions');
		ylabel('variance');
	end
	axis square;
	axis([1 2800 1e-5 1]);
	set(gca,'ytick',10.^[-6:1:0],'xtick',10.^[0:3]);
	title(tstr{k}, 'fontweight', 'normal', 'fontsize',10,'color',cm(k,:))
end

i=i+1;
hs{i}=my_subplot(3,2,4, [.8 .8]);
hold all;
asim = [];
plot([0 2], [0 2], 'k--');
for k=1:4
	if k<4
		alp = squeeze(gs.alp(:, k, :));
		alpGT = gs.alpGT;
	else
		alp = dc.alp;
		alpGT = dc.alpGT;
	end
	errorbar(alpGT, nanmean(alp,2),nanstd(alp,1,2),...
		'.-','color',cm(k,:),'markersize',10,'linewidth',1);
end
box off;
xlabel('ground-truth power law exponent');
ylabel('power law exponent');
axis square;
grid on;
axis([0.4 1.64 0.4 1.64]);
%ylim([0.97 1.03])
%set(gca,'xtick',[0:10:40]);

specSim=squeeze(gs.specSim(:,:,3,:));

ip0=6;
for k=1:3
	i=i+1;
	hs{i}=my_subplot(3,3,k+6,[xh, yh]);
	hs{i}.Position(2) = hs{i}.Position(2) - .03;
	loglog(specSimGT(:,k), 'color',[.3 .3 .3]);
	hold all;
	loglog(specSim(:,k,ip0),'color',cm(3,:));
	loglog(specSimPCA(:,k,ip0), 'color',[0 .6 0]);
	
	
	box off;
	grid on;
	grid minor;
	grid minor;
	%if k==1
	xlabel('dimensions');
	ylabel('variance');
	%end
	axis square;
	axis([1 2800 1e-5 1]);
	set(gca,'ytick',10.^[-6:2:0]);
	text(1,1,sprintf('\\alpha_{GT} = %1.1f',alpGT(k)), 'fontweight', 'bold',...
		'fontsize',10,'color',[.3 .3 .3],'HorizontalAlignment','right')
	text(1,.85,'cvPCA', 'fontweight', 'bold',...
		'fontsize',10,'color',cm(3,:),'HorizontalAlignment','right')
	text(1,.7,'PCA', 'fontweight', 'bold',...
		'fontsize',10,'color',[0 .6 0],'HorizontalAlignment','right')
	
	if k==1
		text(-.1,1.27, 'cvPCA vs PCA on model with additive + gain noise');
	end
	set(gca,'ytick',10.^[-6:1:0],'xtick',10.^[0:3]);
end



for j = 1:length(hs)
	axes('position',hs{j}.Position);
	axis off;
	if j > 2 & j<7
		text(-.4,1.3,char(96+j),'fontsize',12,'fontweight','bold');
	elseif j==1
		text(-.8,1.1,char(96+j),'fontsize',12,'fontweight','bold');
	elseif j==2
		text(-.5,1.1,char(96+j),'fontsize',12,'fontweight','bold');
	elseif j==7
		text(-.1,1.05,char(96+j),'fontsize',12,'fontweight','bold');
	else
		text(-.4,1.05,char(96+j),'fontsize',12,'fontweight','bold');
	end
	%text(-.2,1.15,tstr{j},'fontsize',8);
	
end

%%
print(fullfile(matroot,'suppfig_sims_all.pdf'),'-dpdf');
