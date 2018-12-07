function suppfig_gabors(matroot)

results0=load(fullfile(matroot,'gabor_fits.mat'));
resultsNorm=load(fullfile(matroot,'gabor_fits_wnorm.mat'));

%%
dex = 6;
results=results0;
rf = results.rfstats{dex};
[cRF] = plotGaborRFs(results.Ly, results.Lx, rf);
rfNorm = resultsNorm.rfstats{dex};

%%
close all;
default_figure([10 1 8 5]);

%%
xh = .5;
yh = .5;
i=0;
clear hs;
clf;
cm = colormap('parula');
cm = cm(1:9:end,:);

i=i+1;
results=results0;
ineuB = find(results.vtest{dex} > .05);
ineus = ineuB(abs(results.rfstats{dex}(1,ineuB)-0.0500)<.005 & results.rfstats{dex}(2,ineuB)==6);
ineuEx(1) = ineus(49);
istats = results.rfstats{dex}(:,ineuEx(1));

% -------- EXAMPLE NEURON ---------------------------
j=1;
hs{i}=my_subplot(3,5,1,[.75 .75]);
hs{i}.Position(1) = hs{i}.Position(1) + .03;
hs{i}.Position(2) = hs{i}.Position(2)-.04;
imagesc(cRF(:,:,ineuEx(j)),[-1 1]*.25);
axis image;
axis([0 270 0 67]);
hold all;
plot([90 90],[0 67],'k');
plot([180 180],[0 67],'k');
colormap(hs{i},redblue);
%set(gca,'ytick',[13 60+13],'yticklabel',{'30','-30'},'xtick',[1 45 90],'xticklabel',{'-45','0','45'});
ylabel('Y (\circ)')
xlabel('X (\circ)')

xt = -.2;
yt=3.5;
dy = .3;
text(xt,yt+.15,'Example fit')
text(xt,-dy*1+yt,'spatial frequency: 0.05 cpd','fontsize',6)
text(xt,-dy*2+yt,['spatial size: 6' char(176)],'fontsize',6)
text(xt,-dy*3+yt,'ratio (Y/X): 2.0','fontsize',6)
text(xt,-dy*4+yt,['orientation: 67.5' char(176)],'fontsize',6)
text(xt,-dy*5+yt,['phase: 135' char(176)],'fontsize',6)
text(xt,-dy*6+yt,['complexity: 0.47'],'fontsize',6)

tstr = {{'spatial frequency','(cycles per degree)'}, {['spatial size (' char(176) ')']},'ratio (Y/X)',...
	{['orientation (' char(176) ')']},{['phase (' char(176) ')']},'complexity'};

for wnorm=0:1
	if wnorm
		results=resultsNorm;
	end
	
	% ------- HISTOGRAM OF STATS ---------------------------
	ym = [.5 .6 .65 .3 .25 0.45];
	flds = fields(results.gb);
	for k = 1:6
		hp=my_subplot(3,8,k+2+wnorm*8,[.5 .5]);
		i=i+1;
		hs{i}=hp;
		
		for d = 1:7
			ineu = results.vtest{d} > .05 ;
			
			if k<6
				ipar=results.rfstats{d}(k,ineu)';
				ibin = results.gb.(flds{k});
			else
				ipar=1-results.rfstats{d}(8,ineu)';
				ibin = [0:.1:1];
			end
			pbin = ibin;
			dbin = ibin(2)-ibin(1);
			ibin = [ibin(1)-dbin/2 ibin + dbin/2];
			nbin = histcounts(ipar,ibin);
			nbin(isnan(nbin)) = 0;
			nbin = nbin/nansum(nbin);
			if k > 3 && k < 6
				histogram(ipar*180/pi, ibin*180/pi,'EdgeColor', cm(d, :), 'DisplayStyle', 'stairs',...
					'Linewidth', 1,'normalization','probability')
				hold all;
			else
				histogram(ipar, ibin,'EdgeColor', cm(d, :), 'DisplayStyle', 'stairs',...
					'Linewidth', 1,'normalization','probability')
				hold all;
			end
		end
		xlabel(tstr{k});
		axis tight;
		%axis square;
		box off;
		ylim([0 ym(k)]);
		ylabel('fraction');
		axis square;
		if k==1 && wnorm
			text(-4.5,1.8,{'with divisive normalization','     (statistics)','','','','','','(divisive normalization','   as dotted line)'},'FontAngle','italic','HorizontalAlignment','left','fontsize',10)
		end
		
	end
	
end

load(fullfile(matroot,'gabor_spectrum_wnorm.mat'));
specNorm = specS;
load(fullfile(matroot,'gabor_spectrum.mat'));

stimset = {{'original',''}, {'whitened','(partially)'},...
    {'8D images',''},{'4D images',''}, {'spatially','localized'},...
    {'1D drifting','gratings'},{'sparse noise',''}};
id=[1 2 5 7 3 4 6];
for K=1:7
	i=i+1;
	hs{i}=my_subplot(3,7, K+14,[.6 .6]);
	hs{i}.Position(1) = hs{i}.Position(1) + .005*(7-K);
	trange0 =  [10:min(500,numel(specS{id(K)})-1)];
	[a,ypred,~,r] = get_powerlaw(specS{id(K)},trange0);
	[anorm,ypred,~,r] = get_powerlaw(specNorm{id(K)},trange0);
	loglog(specS{id(K)},'m');
	hold all;
	loglog(specNorm{id(K)},'k--');
	%loglog(ypred);
	title([a,anorm]);
	ylim([1e-5 1]);
	xlim([0 2800]);
	
	text(1,1,sprintf('\\alpha=%1.2f',a),'fontsize',8,...
				'fontweight','bold','color','m','HorizontalAlignment','right')
	text(1,.8,sprintf('\\alpha=%1.2f',anorm),'fontsize',8,...
				'fontweight','bold','color','k','HorizontalAlignment','right')
	title(stimset{id(K)},'fontweight','normal')
	grid on;
	grid minor;
	grid minor;
	axis square;
	box off;
	set(gca,'xtick',10.^[0:4],'ytick',10.^[-5:0]);
		
	if K==1
		xlabel('PC dimension');
		ylabel('variance')
	else
		%set(gca,'xticklabel',{},'yticklabel',{});
	end
end


for j = 1:length(hs)
	hp=hs{j}.Position;
	hp(1)=hp(1)-.05;
	hp(2)=hp(2)+.06;
	
	axes('position',hp);
	axis off;
	if j ==1
		jy=1.05;
		jx=0;
	elseif j<14 && j>1
		jy = .75;
		jx = .0;
	else
		jy=.95;
		jx=.03;
	end
	text(jx,jy,char(96+j),'units','normalized','fontsize',11,'fontweight','bold','fontangle','normal');
	hp(1)=hp(1)+.02;
	axes('position',hp);
	axis off;
	%text(jx-.04,jy-0.02,ttl{j},'units','normalized','fontsize',10,'fontangle','normal');
	
end

%%
print('fig/supp_gabors.pdf','-dpdf');








