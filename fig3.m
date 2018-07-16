% plot all stats fig3
clear all;

% datapath
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp';
matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';

%%

neur = load(fullfile(matroot,'eigsAllStats.mat'));
gabor = load(fullfile(matroot,'gaborCSfits2natimg.mat'));
load(fullfile(dataroot,'allimgs.mat'));
load(fullfile(dataroot,'sparseSTATS.mat'));
neur.specS{7} = vALL;
evs{6} = [1 1e-5*ones(1,99)];
evs{7} = ones(1,100)/100;
oimg = repmat(sin(([-199:200])/3),200,1);
oimg = imrotate(oimg,45);
oimg = oimg([150:249],[150:249]);
img{6} = oimg;
img{7} = ceil(rand(11,11) - .95) - ceil(rand(11,11) - .95);

%%
close all
xf = 4.5;
yf = 7;
HF=default_figure([11 3 xf yf]);
%%

id = [1 2 5 7 3 4 6];

cmap = [.5 .5 .5; 0 0 1; 1 0 1; 0 .5 0];

trange = 10:500;
trange0 = 25:500;

clf;

%set(gcf,'DefaultTextFontSize',12);
%set(gcf,'DefaultAxesFontSize',10);

%figure('position', [0 0 xf yf])

stimset = {{'original'}, {'whitened','(partially)'},...
    {'8D images'},{'4D images'}, {'spatially localized'},...
    {'1D drifting gratings'},{'sparse noise'}};
xtitles = {{'Example image'}, {'Image'}, {'Neural'}, ...
    {'Gabor'},{'Alexnet'}};



dy = .94/(numel(id));
yh = .76*dy;
xh = .2;

XPOS = .04 + (xh+.022)*[0:3];
XPOS(2:end) = XPOS(2:end)+.05;
clear hs;
ytitle = 1.24;
txt = {'x2800', 'x2800', 'x2800', 'x2800', 'x2800', 'x32', 'x3600'};
clear hs;
for K = 1:numel(id)
    % ///////////////////////////////////////////////////////////////////
    if K==1
        hs{K}=axes('Position', [XPOS(1), .02 + (numel(id)-K)*dy + .02, xh*.95, yh*.95]);
    else
        hs{K}=axes('Position', [XPOS(1), .02 + (numel(id)-K)*dy, xh*.95, yh*.95]);
    end
    
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
		
		text(3.9, ytitle+.01, 'Eigenspectrum', 'HorizontalAlignment', 'center',...
            'fontsize',10,'fontangle','normal','verticalalign','bottom');
	end
    
    % ///////////////////////////////////////////////////////////////////
    for jp = 2:4
        if K==1
            axes('Position', [XPOS(jp), .02 + (numel(id)-K)*dy+.02, xh, yh]);
            
        else
            axes('Position', [XPOS(jp), .02 + (numel(id)-K)*dy, xh, yh])
        end
        
        
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
                lam     = gabor.specA{id(K)} / sum(gabor.specA{id(K)});
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
        set(gca, 'xtick', [1 10 100 1000], 'xticklabel',{'1','10','100 ','1000'})
        set(gca, 'ytick', 10.^[-5:-1])
        
        box off
        if K==1
			text(.5, ytitle-.05, xtitles{jp}, 'HorizontalAlignment', 'center',...
                'fontsize',8,'fontangle','normal','color',cmap(jp-1,:));
		end
		
		if jp==2 && K==1
			set(gca, 'xtick', [1 10 100 1000]);
			set(gca, 'ytick', 10.^[-5:-1]);
			ylabel('variance');
			xlabel('PC dimension');
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

%
% -------------- LETTERS
hp=.04;
hy=1.28;
deffont=10;
for j = [1:length(hs)]
    if j==1
        hp0 = hp;
    else
        hp0=hp;
    end
    hpos = hs{j}.Position;
    axes('position', [hpos(1)-hp0 hpos(2)+hpos(4)*hy(1) .01 .01]);
    text(0,0, char(96+j),'fontsize',12,'fontweight','bold','fontangle','normal');
    axis([0 1 0 1]);
    axis off;
end

save(fullfile(matroot, 'alphas.mat'),'alp','aall');

%%
print('../figs/fig3wgaborsnew.pdf','-dpdf');





















