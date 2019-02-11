% increasing neurons and stimuli in all image datasets
function suppfig_incrNeuStim(dataroot,matroot)

load(fullfile(dataroot,'dbstims.mat'));

%%

close all;
pos_inches = [1 3 7.5 7.5];
HF = default_figure(pos_inches);

%%
clf;
clear hs;
titlestr = {'Natural images','Spatially whitened images','8D images', ...
	'4D images', 'Spatially localized images', '1D drifting gratings'};

blu = [0 0 1];
red = [1 0 0];
green = [0 .5 0];

nfrac = 2.^[0:-1:-6];
sfrac = 2.^[0:-1:-6];
nl =7;


% second part of plot with all stimulus types
kp = [2 5 3 4 6];
ip=0;
for K = 1:5
	load(fullfile(matroot,sprintf('eigs_incneurstim_%s.mat',stimset{kp(K)})));
	
	for ij = 1:2
		if ij == 1
			col = [linspace(blu(1), red(1), nl); ...
				linspace(blu(2), red(2), nl); linspace(blu(3), red(3), nl)]';
		else
			col = [linspace(blu(1), green(1), nl); ...
				linspace(blu(2), green(2), nl); linspace(blu(3), green(3), nl)]';
		end
		cols{ij}=col;
		
		my_subplot(5,4,ij+(K-1)*4,[.55 .55]);
		if K==1
			ip=ip+1;
			hs{ip}=gca;
		end
		p=NaN*zeros(nl, size(specS{1,ij},2));
		r=NaN*zeros(nl, size(specS{1,ij},2));
		sA = NaN*zeros(2800, 10, size(specS,2));
		
		irange = 1:size(specS{1,ij},2);
		
		for j = 1:nl
			clear sA;
			fmax = 1e4;
			for k=irange
				ss=specS{j,ij}(:,k);
				fnan = find(isnan(ss),1)-1;
				if isempty(fnan); fnan = numel(ss)-1; end
				if ij == 1
					if fnan > nfrac(j)*NumNeur(k)
						fnan = nfrac(j)*NumNeur(k);
					end
				end
				trange0 = 11:max(12,min(500, (round(fnan*.5))));
				if kp(K)==6
					trange0 = 11:31;
					if ij==2
						trange0 = 11:31*sfrac(j);
					end
					fnan = numel(trange0);
				end
				if ~isempty(trange0)
					[p(j,k), ypred, b(j,k), r(j,k)] = get_powerlaw(ss, trange0);
				end
				tplot = round(min(min(500,fnan*.5), numel(ss)));
				sA(1:tplot,k) = ss(1:tplot)/nansum(ss(1:tplot));
				fmax = min(tplot, fmax);
				
			end
			loglog(nanmean(sA(1:fmax,:),2), 'Color', col(j,:));
			hold all;
			if K==1
				text(1.35, 1-(j-1)*.12, sprintf('%2.3f', nfrac(j)), 'HorizontalAlign', 'right', ...
					'Color', col(j,:),'fontsize',8,'fontangle','normal');
			end
		end
		if ij ==1
			text(-.35, 1.2, titlestr{kp(K)},'fontsize',10)
		end
		if K==1
			if ij == 1
				text(1, 1, {'fraction of all', 'neurons:'}, 'HorizontalAlign', 'right','fontsize',8)
				
			else
				text(1, 1, {'fraction of all', 'stimuli:'}, 'HorizontalAlign', 'right','fontsize',8)
			end
		end
		box off
		if kp(K)~=6
			ylim(10.^[-4 -.5])
			xlim([1 500])
		else
			axis([1 31 0.005 1]);
		end
		set(gca, 'xtick', 10.^[0 1 2 3], 'ytick', 10.^[-5:1:-1])
		ylabel('variance')
		xlabel('dimension')
		grid on;
		grid minor;
		grid minor;
		axis square
		%
		ps{ij} = p;
		rs{ij} = r;
	end
	for kt = 1:2
		if kt==1
			wp = rs;
		else
			wp = ps;
		end
		my_subplot(5,4,2+kt+(K-1)*4,[.55 .55]);
		if K==1
			ip=ip+1;
			hs{ip}=gca;
		end
		
		for ij = 1:2
			p = wp{ij};
			semilogx(nfrac, nanmean(p,2),'k');
			hold all;
			for j = 1:numel(nfrac)
				errorbar(nfrac(j), nanmean(p(j,:)), nanstd(p(j,:))/sqrt(size(p,2)),'.','color',cols{ij}(j,:),'markersize',10);
			end
			
		end
		axis tight;
		box off;
		if kt == 1
			ylabel({'correlation','coefficient'});
			ylim([.4 1.02]);
		else
			ylabel({'power law','exponent'});
			ylim([0 2.5]);
			if kp(K)==6
				ylim([0 6]);
			end
		end
		set(gca, 'xtick', [0.1 1 2], 'xticklabel',{'0.1','1', '2'});
		xlabel('fraction of neurons/stimuli');
		axis square;
	end
end


for j = 1:length(hs)
	axes(hs{j});
	%if j < 5
	%	jy = 1.2 ;
		
	%else
		jy = 1.28;
		
	%end
	jx = -.5;
	text(jx,jy,char(96+j),'units','normalized','fontsize',12,'fontweight','bold','fontangle','normal');
end

%
print('fig/supp_incneurstim.pdf','-dpdf','-fillpage');






























