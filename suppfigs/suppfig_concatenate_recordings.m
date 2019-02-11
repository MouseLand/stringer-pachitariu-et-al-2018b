function suppfig_concatenate_recordings(matroot)

conc=load(fullfile(matroot, 'combinedSessions.mat'));
gb = load(fullfile(matroot,'gabor_fits.mat'));

%%

close all;
pos_inches = [1 3 7.5 2.5];
HF = default_figure(pos_inches);

%%

clf;
clear hs;
ip = 0;

for k=1:3
	ip=ip+1;
	hs{ip} = my_subplot(2,4,k+4,[.55 .55]);
	hs{ip}.Position(2) = hs{ip}.Position(2) + .0;
	loglog(conc.specS{k}{1}, 'color',[.5 .5 1]);
	hold all;
	loglog(conc.yfit{k}{1}, 'k');
	grid on;
	grid minor;
	grid minor;
	axis square;
	box off;
	ylim(10.^[-5.5 -.3])
	xlim([0 2800])
	set(gca, 'xtick', [1 10 100 1000]);
	set(gca, 'ytick', 10.^[-5:-1]);
	ylabel('variance');
	xlabel('PC dimension');
	text(.45, .8, sprintf('\\alpha=%2.2f', conc.alp(k)),'fontsize',8,...
		'fontweight','bold')
	%text(-.15, 1.05, sprintf('      RF: (%2.1f, %2.1f)', conc.avgRF{j}), 'fontsize', 8);
	%ht.Position(2) = ht.Position(2) - .4;
	
	hs{ip} = my_subplot(2,4,k,[.55 .55]);
	hs{ip}.Position(2) = hs{ip}.Position(2) -.09;
	dd=0;
	cm=[0 0 .5; .4 .6 .8];
	for d = conc.ipairs{k}
		dd=dd+1;
		ineu = gb.vtest{d} > .05;
		y=gb.rfstats{d}(6,ineu)' - 34;
		x=gb.rfstats{d}(7,ineu)' - 135;
		xneg = mean(x) - prctile(x,5);
		xpos = prctile(x,95) - mean(x);
		yneg = mean(y) - prctile(y,5);
		ypos = prctile(y,95) - mean(y);
		errorbar(mean(x),mean(y),yneg,ypos,xneg,xpos,'color',cm(dd,:),...
			'linewidth',1)
		hold all;
	end
	ylabel({'vertical angle'})
	xlabel('horizontal angle')
	axis image;
	axis([-135 135-90 -67/2 67/2]);
	set(gca,'ytick',[-30 30],'xtick',[-90 0 90]);
	hold all;
	plot(-45*[1 1], [-45 45],'k');
	plot(45*[1 1], [-45 45],'k');
	if k==1
		text(-.5,2.38,'Two recordings with similar RFs concatenated');
	end
end


%

blu = [0 0 1];
red = [1 0 0];
green = [0 .5 0];

nfrac = 2.^[0:-1:-7];

nl =  length(nfrac)-2;
nfrac = nfrac(1:nl);

% compute powerlaws for specS
p=[];
for n = 1:nl
	fmax = 1e4;
	for k=1:3
		ss=conc.specS{k}{n};
		fnan = find(isnan(ss),1)-1;
		if isempty(fnan); fnan = numel(ss)-1; end
		if fnan > nfrac(k)*conc.numNeu(k)
			fnan = nfrac(k)*conc.numNeu(k);
		end
		trange0 = 11:max(12,min(500, (round(fnan*.5))));
		if k==1
			trange0 = 11:500;
		end
		if ~isempty(trange0)
			[p(k,n), ypred, b(k,n), r(k,n)] = get_powerlaw(ss, trange0);
		end
		tplot = round(min(min(500,fnan*.5), numel(ss)));
		sA(1:tplot,n) = ss(1:tplot)/nansum(ss(1:tplot));
		fmax = min(tplot, fmax);		
	end
end

ip=ip+1;
hs{ip} = my_subplot(1,4,4,[.55 .55]);
hs{ip}.Position(2) = hs{ip}.Position(2) - .01;
col = [linspace(blu(1), red(1), nl-1); ...
	linspace(blu(2), red(2), nl-1); linspace(blu(3), red(3), nl-1)]';
col = [.5 .5 1; col];

semilogx(nfrac * 2, nanmean(p,1),'k');
hold all;
for n = 1:numel(nfrac)
	errorbar(nfrac(n)*2, nanmean(p(:,n)), nanstd(p(:,n))/sqrt(size(p,2)),'.','color',col(n,:),'markersize',10);
end
%errorbar(2, nanmean(conc.alp), nanstd(conc.alp)/sqrt(2), '.', 'color',[.5 .5 1],'markersize',10);
%plot([2, nfrac],ones(8,1),'k--','linewidth',.5);
axis tight;
box off;
ylabel({'power law','exponent'});
ylim([0. 2]);
xlim([0.05 2]);
set(gca, 'xtick', [0.1 1 2]);
xlabel('fraction of neurons');
axis square;
grid on;
grid minor;
grid minor;



for k = 1:length(hs)
	axes('position',hs{k}.Position);
	axis off;
	if k < 4
		text(-.5,1.3,char(96+k),'fontsize',12,'fontweight','bold');
	else
		text(-.4,1.05,char(96+k),'fontsize',12,'fontweight','bold');
	end
	%text(-.2,1.15,tstr{j},'fontsize',8);
	
end

%%
print('fig/supp_conc.pdf','-dpdf');