function suppfig_gabors(matroot)

results=load(fullfile(matroot,'gabor_fits.mat'));

%%
dex = 6;
rf = results.rfstats{dex};
[cRF] = plotGaborRFs(results.Ly, results.Lx, rf);


%%
close all;
default_figure([10 1 5 5]);

%%
xh = .5;
yh = .5;
i=0;
clear hs;
clf;
cm = colormap('parula');
cm = cm(1:9:end,:);

i=i+1;
ineuB = find(results.vtest{dex} > .05);
ineus = ineuB(abs(results.rfstats{dex}(1,ineuB)-0.0700)<.005 & results.rfstats{dex}(2,ineuB)==4);
ineuEx(1) = ineus(10);
istats = results.rfstats{dex}(:,ineuEx(1));

% -------- EXAMPLE NEURON ---------------------------
j=1;
hs{i}=my_subplot(3,2,1,[.75 .75]);
hs{i}.Position(1) = hs{i}.Position(1) + .38;
hs{i}.Position(2) = hs{i}.Position(2);
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

text(-.95,2.6-1.35,'Example fit')
text(-.95,2.35-1.35,'spatial frequency: 0.07 cpd','fontsize',8)
text(-.95,2.1-1.35,['spatial size: 4' char(176)],'fontsize',8)
text(-.95,1.85-1.35,'ratio (Y/X): 1.5','fontsize',8)
text(-.95,1.6-1.35,['orientation: 45' char(176)],'fontsize',8)
text(-.95,1.35-1.35,['phase: 112.5' char(176)],'fontsize',8)
text(-.95,1.1-1.35,['complexity: 0.58'],'fontsize',8)

tstr = {{'spatial frequency','(cycles per degree)'}, {['spatial size (' char(176) ')']},'ratio (Y/X)',...
	{['orientation (' char(176) ')']},{['phase (' char(176) ')']},'complexity'};

% ------- HISTOGRAM OF STATS ---------------------------
ym = [.5 .55 .6 .3 .15 0.45];
flds = fields(results.gb);
for k = 1:6
	hp=my_subplot(3,3,k+3,[.5 .5]);
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
end

for j = 1:length(hs)
	hp=hs{j}.Position;
	hp(1)=hp(1)-.05;
	hp(2)=hp(2)+.06;
	
	axes('position',hp);
	axis off;
	if j ==1
	    jy=.7;
		jx=-.88;
	else	
		jy = 1;
		jx = -0;
	end
	text(jx,jy,char(96+j),'units','normalized','fontsize',11,'fontweight','bold','fontangle','normal');
	hp(1)=hp(1)+.02;
	axes('position',hp);
	axis off;
	%text(jx-.04,jy-0.02,ttl{j},'units','normalized','fontsize',10,'fontangle','normal');
	
end

%%
print('fig/supp_gabors.pdf','-dpdf');








