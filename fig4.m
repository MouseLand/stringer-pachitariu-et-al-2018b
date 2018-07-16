clear all;

matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';
load(fullfile(matroot,'scalefree.mat'));
alpsim = alp;
load(fullfile(matroot,'alphas'));

%%
close all;
HF=default_figure([1 1 4.5 7]);

%%
deffont = 8;
clf;
clear hs;
hs{1}=my_subplot(6,1,1,[.3 .9]);
hs{1}.Position(2) = hs{1}.Position(2) - .01;
hs{1}.Position(1) = hs{1}.Position(1) - .12;
% plot of alphas
D = [100*ones(2,1); 8; 4; 100; 1; 100];
serr = cellfun(@std,aall);
serr = serr./sqrt(cellfun(@numel,aall)-1);
cm = colormap('winter');
cm = cm(round(linspace(1,64,7)),:);
ik = [1 2 5 6 3 7 4];
stimset = {{'original'}, {'whitened (partially)'},...
    {'8D images'},{'4D images'}, {'spatially localized'},...
    {'1D drifting gratings'},{'sparse noise'}};

for j = 1:numel(D)
    plot(1+2./D(j),nanmean(aall{j}),'o','color',cm(ik(j),:),...
        'markersize',4); %'MarkerFaceColor',cm(ik(j),:),
    hold all;
    text(1.1,(ik(j))*.15,stimset{j},'color',cm(ik(j),:),'fontsize', 10);
end
for j = 1:numel(D)
    plot(1+2./D(j),alp(3,j),'x','color',cm(ik(j),:),...
        'markersize',6);
end

hold all;
plot([1:3.1],[1:3.1],'k--');
%plot([1 4 8], 1 + 2./[1 4 8],'k');
xlabel('1 + 2/d (d=stimulus dimensionality)');
ylabel('power law exponent \alpha');
box off;
axis tight;
ylim([.85 4.7]);
text(-.8,1,'o Neural \alpha');
text(-.8,.8,'x Gabor \alpha');


cm = colormap('jet');
cs = cm(round(exp(linspace(log(1),log(64),100))),:); 
cs = cs(end:-1:1,:);
cm = cm(round((linspace(1,64,15))),:);
cm = cm(end:-1:1,:);
    
for k = 1:5
    hs{k+1}=my_subplot(7,3,1+(k+1)*3);
    if k==1
        hs{k+1}.Position(2) = hs{k+1}.Position(2)+.03;
    else
        hs{k+1}.Position(2) = hs{k+1}.Position(2)-.01;
    end
    
    hold all;
    if k>2
        ip = round(exp(linspace(log(2),log(64),15)));
    else
        ip = round(linspace(1,size(exresp{k},1),15));
    end
    ij = 0;
    for j = ip
        ij = ij+1;
        plot(exresp{k}(j,:),'color',cm(ij,:))
    end
    axis tight;
    axis off;
    if k>2
        title(sprintf('cos(n\\theta) / n^{\\alpha/2}, \\alpha=%d',alpsim(k)),...
            'fontsize',8,'fontweight','normal');
    elseif k==1
        title('low-D tuning','fontsize',8,'fontweight','normal');
    else
        title('efficient coding','fontsize',8,'fontweight','normal');
    end
    axis square;
    if k==1
        text(-.2,1.5,'Neural responses','fontsize',10,'fontweight','normal');
    end
    
    s = spec{k};
    hp=my_subplot(7,3,2+(k+1)*3);
    if k==1
        hp.Position(2) = hp.Position(2)+.03;
    end
    
    loglog(s(1:end-1)/sum(s(1:end-1)),'k');
    hold all;
    for j = 100:-1:1
        plot(j,s(j)/sum(s(1:end-1)),'.','color',cs(j,:),'markersize',10)
    end
    axis tight;
    box off;
    grid on;
    grid minor;
    grid minor;
    if k==1
        xlabel('PC dimension');
        ylabel('variance');
    end
    set(gca,'ytick',10.^[-3:0],'yticklabel',{'0.001','0.01','0.1','1'},...
        'xtick',10.^[0:2],'xticklabel',{'1','10','100'},'fontsize',deffont);
    ylim(10.^[-3.5 0]);
    xlim(10.^[0 2]);
    if k>2
        text(.5,.8,sprintf('\\alpha = %d',alpsim(k)),'fontsize',10,'fontangle','normal','fontweight','bold');
    end
    axis square;
    if k==1
        text(-.2,1.5,'Eigenspectrum','fontsize',10,'fontweight','normal');
    end
    
    wproj = exproj{k};
    np = size(wproj,2);
    hp=my_subplot(7,3,3+(k+1)*3,[.75 .75]);
    if k==1
        hp.Position(2) = hp.Position(2)+.03;
    end
    
    plot3(wproj(1,1:2:end),wproj(2,1:2:end),zeros(1,np/2),'color',.7*[1 1 1],'linewidth',.5);
    hold all;
    plot3(wproj(1,1:2:end),wproj(2,1:2:end),wproj(3,1:2:end)-min(wproj(3,1:2:end)),'k','linewidth',.5);
    grid on;
    axis tight;
    if k==1
        text(-.2,1.45,'3D projection','fontsize',10,'fontweight','normal');
    end
    set(gca,'fontsize',deffont);
    axis square;
    
end

%%

for j = 1:length(hs)
    axes(hs{j});
    if j==1
        jy = 1.13 ;
        jx = -1.;        
    else
        jy = 1.3;
        jx = -.5;
    end
    text(jx,jy,char(96+j),'units','normalized','fontsize',12,'fontweight','bold','fontangle','normal');
end

%%
print('../figs/fig4new.pdf','-dpdf');
































