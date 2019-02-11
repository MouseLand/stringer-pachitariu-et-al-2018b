function fig3(dataroot,matroot)

neur = load(fullfile(matroot,'eigs_and_stats_all.mat'));
gabor = load(fullfile(matroot,'gabor_spectrum.mat'));
% example images
load(fullfile(dataroot,'allimgs.mat'));
% sparse noise eigenvectors
load(fullfile(dataroot,'sparseSTATS.mat'));
neur.specS{7} = vALL;
evs{6} = [1 1e-5*ones(1,99)];
evs{7} = ones(1,100)/100;
oimg = repmat(sin(([-199:200])/3),200,1);
oimg = imrotate(oimg,45);
oimg = oimg([150:249],[150:249]);
img{6} = oimg;
img{7} = ceil(rand(11,11) - .95) - ceil(rand(11,11) - .95);


close all
xf = 9;
yf = 4.2;
HF=default_figure([11 3 xf yf]);

%%

id = [1 2 5 7 3 4 6];

cmap = [.5 .5 .5; 0 0 1; 1 0 1; 0 .5 0];

trange = 11:500;

clf;

%set(gcf,'DefaultTextFontSize',12);
%set(gcf,'DefaultAxesFontSize',10);

%figure('position', [0 0 xf yf])

stimset = {{'original'}, {'whitened','(partially)'},...
    {'8D images'},{'4D images'}, {'spatially','localized'},...
    {'1D drifting','gratings'},{'sparse noise'}};
xtitles = {{''}, {'Image spectrum'}, {'Neural spectrum'}, ...
    {'Gabor spectrum'},{'Alexnet'}};



clear hs;
ytitle = 1.2;
txt = {'x2800', 'x2800', 'x2800', 'x2800', 'x2800', 'x32', 'x3600'};
clear hs;
for K = 1:numel(id)
    % ///////////////////////////////////////////////////////////////////
    hs{K} = my_subplot(4, 10, K);
	hs{K}.Position(1) = hs{K}.Position(1) + 0.03;
	hs{K}.Position(2) = hs{K}.Position(2) - 0.015;
    imagesc(img{id(K)}, [-1 1])
    axis square;
    colormap('gray')
    
    axis off
    text(0, 1., stimset{id(K)}, 'HorizontalAlign', 'Left','verticalalign','bottom',...
        'fontsize',8)
    
    text(.95, -.0, txt{id(K)},'HorizontalAlign', 'Right','VerticalAlign', 'top','Fontsize', 6)
    if K==1
        text(.6, ytitle+.01, xtitles{1}, 'HorizontalAlignment', 'center',...
            'fontsize',10,'fontangle','normal','verticalalign','bottom');
		
		
	end
    
    % ///////////////////////////////////////////////////////////////////
    for jp = 2:4
        hp=my_subplot(4, 10, K + (jp-1)*10);
		hp.Position(1) = hp.Position(1) + 0.03;
		hp.Position(2) = hp.Position(2) + 0.01*(5-jp);
		switch jp
            case 2
                ss = evs{id(K)};
                ss = ss(:)/sum(ss(:));
                if id(K)==7 || id(K)==5
                    trange0 = 3:100;
                elseif id(K)==6
                    trange0 = 3:32;
                else
                    trange0 = 25:500;
                end
            case 3
                if id(K) == 6
                    lam = nan(32, numel(neur.specS{id(K)}));
                    trange0 = [11:30];
                else
                    lam = nan(2800, numel(neur.specS{id(K)}));
                    trange0  = 11:500;
                end
                
                for k = 1:numel(neur.specS{id(K)})
                    l = numel(neur.specS{id(K)}{k});
                    lam(1:l,k) =  gather(neur.specS{id(K)}{k});
				end
                
                lam     = lam ./ nansum(lam,1);
                aall{id(K)} = [];
                for k = 1:size(lam,2)
                    ss = lam(:,k);
                    %ss = my_conv2(ss, 1, 1);
                    [p, ypred, b] = get_powerlaw(ss, trange0);
                    aall{id(K)}(k) = p;
                end
                
                ss      = nanmean(lam,2);
                errbar  = nanstd(lam,1,2)/sqrt(size(lam,2)-1);
                
            case 4
                % same trange
                lam     = gabor.specS{id(K)} / sum(gabor.specS{id(K)});
                %ss = my_conv2(ss, 1, 1);
                ss = lam;
			case 5
				lay = 11;
				lam     = alex.specS{id(K),lay} / sum(alex.specS{id(K),lay});
                %ss = my_conv2(ss, 1, 1);
                ss = gather(lam);
		end
        
        
        [p, ypred, b] = get_powerlaw(ss, trange0);
        alp(jp-1, id(K)) = p;
        
        loglog(ss,'color',cmap(jp-1,:));
        hold on
        if jp==3
            H=shadedErrorBar(1:numel(ss), ss, errbar, {'color',cmap(jp-1,:)});
		end
        plot(ypred, 'k');
        
        if K < 5 || jp > 2
            text(.4, .95, sprintf('\\alpha=%2.2f', p),'fontsize',8,...
				'fontweight','bold','color',cmap(jp-1,:))
        end
        grid on;
        grid minor;
        grid minor;
        box off
        
        box off
        if K==1
			text(.5, ytitle, xtitles{jp}, 'HorizontalAlignment', 'center',...
                'fontsize',8,'fontangle','normal','color',cmap(jp-1,:));
		end
		
		if K==1
			set(gca, 'xtick', [1 10 100 1000]);%,'xticklabel',{'1','10','100','1000'});
			set(gca, 'ytick', 10.^[-5:2:-1]);
			ylabel('variance');
			text(0,-.27,'PC dimension', 'fontsize',8);
		else
			set(gca, 'xtick', [1 10 100 1000],'xticklabel',{});
			set(gca, 'ytick', 10.^[-5:-1],'yticklabel',{});
		end
        
        grid on;
        grid minor;
        grid minor;
        axis square;
        ylim(10.^[-5.5 -.3])
        xlim([0 2800])
    end
end

D = [100*ones(2,1); 8; 4; 100; 1; 100];
serr = cellfun(@std,aall);
serr = serr./sqrt(cellfun(@numel,aall)-1);
ik = [1 2 5 6 3 7 4];
stimset = {{'original'}, {'whitened (partially)'},...
    {'8D images'},{'4D images'}, {'spatially localized'},...
    {'1D drifting gratings'},{'sparse noise'}};

sp = {'o','x','^','v','+','*','.'};
sps = {'o','x','\Delta','\nabla','+','*','\bullet'};
ms0 = 6;
ms = [ms0 ms0 ms0 ms0 ms0 ms0 15];
hs{K+1} = my_subplot(2,3,3,[.7 .7]);
hs{K+1}.Position(1) = hs{K+1}.Position(1) + 0.02;
hs{K+1}.Position(2) = hs{K+1}.Position(2) + 0.01;
for j = 1:numel(D)
	for k = 1
		plot(1+2./D(j),alp(k+1,j),sp{j},'color',cmap(k+1,:),...
			'markersize',ms(j)); %'MarkerFaceColor',cm(ik(j),:),
	end
    hold all;
end
text(.18, .18, 'a,b,c,d','color','b','fontsize',8);
text(.1, .32, 'e','color','b','fontsize',8);
text(.22, .38, 'f','color','b','fontsize',8);
text(.56,.85, 'g','color','b','fontsize',8);
hold all;
plot([0.5 4.7],[0.5 4.7],'k--');
%plot([1 4 8], 1 + 2./[1 4 8],'k');
xlabel({'1 + 2/d','(d=stimulus dimensionality)'});
ylabel('power law exponent ');
ht=text(-.23,0.82,'\alpha');
set(ht,'rotation',90);
box off;
axis tight;
axis([.5 4.7 0.5 4.7]);
axis square;

hs{K+2} = my_subplot(2,3,6,[.7 .7]);
hs{K+2}.Position(1) = hs{K+2}.Position(1) + 0.02;
hs{K+2}.Position(2) = hs{K+2}.Position(2) + 0.01;
for j = 1:numel(D)
	for k = 2
		plot(1+2./D(j),alp(k+1,j),sp{j},'color',cmap(k+1,:),...
			'markersize',ms(j)); %'MarkerFaceColor',cm(ik(j),:),
	end
    hold all;
end
text(.17, .32, 'a,b','color',cmap(k+1,:),'fontsize',8);
text(.17, .38, 'c','color',cmap(k+1,:),'fontsize',8);
text(.03, .45, 'd','color',cmap(k+1,:),'fontsize',8);
text(.1,.55, 'e','color',cmap(k+1,:),'fontsize',8);
text(.22,.63, 'f','color',cmap(k+1,:),'fontsize',8);
text(.56,1.07, 'g','color',cmap(k+1,:),'fontsize',8);
hold all;
plot([0.5 4.7],[0.5 4.7],'k--');
%plot([1 4 8], 1 + 2./[1 4 8],'k');
xlabel({'1 + 2/d','(d=stimulus dimensionality)'});
ylabel('power law exponent');
ht=text(-.23,0.82,'\alpha');
set(ht,'rotation',90);
box off;
axis tight;
axis([.5 4.7 0.5 4.7]);
axis square;

%
% -------------- LETTERS
hp=.02;
hy=1.28;
deffont=10;
for j = [1:length(hs)]
    if j==length(hs) || j==length(hs)-1
        hy0 = 1.1;
		hp0 = .01;
    else
        hy0=hy;
		hp0=hp;
    end
    hpos = hs{j}.Position;
    axes('position', [hpos(1)-hp0 hpos(2)+hpos(4)*hy0(1) .01 .01]);
    text(0,0, char(96+j),'fontsize',12,'fontweight','bold','fontangle','normal');
    axis([0 1 0 1]);
    axis off;
end

%save(fullfile(matroot, 'alphas.mat'),'alp','aall');

%
print(fullfile(matroot,'fig3.pdf'),'-dpdf');





















