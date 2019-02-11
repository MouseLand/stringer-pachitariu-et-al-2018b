function fig4(matroot)

load(fullfile(matroot,'scalefree.mat'));
alpsim = alp;

%%
close all;
HF=default_figure([1 1 9 3.8]);

%%
deffont = 8;
clf;
clear hs;

cm = colormap('jet');
cs = cm(round(exp(linspace(log(1),log(64),100))),:); 
cs = cs(end:-1:1,:);
cm = cm(round((linspace(1,64,15))),:);
cm = cm(end:-1:1,:);
   
dx=.03;
for k = 1:5
    hs{k}=my_subplot(3,5,+k);
	hs{k}.Position(1) = hs{k}.Position(1)+dx*(5-k);
    
    hold all;
    if k>2
        ip = round(exp(linspace(log(2),log(100),15)));
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
        text(-1.5,.7,{'Tuning curves','(simulations)'},'fontsize',10,'fontweight','normal');
    end
    
    s = spec{k};
    hp=my_subplot(3,5,k+5);
	hp.Position(1) = hp.Position(1)+dx*(5-k);
    hp.Position(2) = hp.Position(2)+0.03;
    
    loglog(s(1:end-1)/sum(s(1:end-1)),'k');
    hold all;
    for j = 100:-1:1
		if k == 2
			plot(exp(((j-1)+1)/10),1/1000,'.','color',cs(j,:),'markersize',10)
		elseif k==1
			plot(j,s(j)/sum(s(1:end-1)),'.','color','k','markersize',10)
		else
			plot(j,s(j)/sum(s(1:end-1)),'.','color',cs(j,:),'markersize',10)
		end
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
        'xtick',10.^[0:3],'xticklabel',{'1','10','100','1000'},'fontsize',deffont);
    ylim(10.^[-3.5 0]);
    xlim(10.^[0 3]);
    if k>2
        text(.5,.8,sprintf('\\alpha = %d',alpsim(k)),'fontsize',10,'fontangle','normal','fontweight','bold');
    end
    axis square;
    if k==1
        text(-1.5,.7,{'Eigen-','spectrum'},'fontsize',10,'fontweight','normal');
    end
    
    wproj = exproj{k};
    np = size(wproj,2);
    hp=my_subplot(3,5,k+10,[.9 .9]);
	hp.Position(1) = hp.Position(1)+dx*(5-k);
	hp.Position(2) = hp.Position(2)+0.01;
    
    
    plot3(wproj(1,1:2:end),wproj(2,1:2:end),zeros(1,ceil(np/2)),'color',.7*[1 1 1],'linewidth',.25);
    hold all;
    plot3(wproj(1,1:2:end),wproj(2,1:2:end),wproj(3,1:2:end)-min(wproj(3,1:2:end)),'k','linewidth',.5);
    grid on;
    axis tight;
    if k==1
        text(-1.2,.7,{'Random','projection'},'fontsize',10,'fontweight','normal');
    end
    set(gca,'fontsize',deffont);
    axis square;
    
end


for j = 1:length(hs)
    axes(hs{j});
    if j==11
        jy = 1.13 ;
        jx = -1.;        
    else
        jy = 1.18;
        jx = -.28;
    end
    text(jx,jy,char(96+j),'units','normalized','fontsize',12,'fontweight','bold','fontangle','normal');
end

%%
print(fullfile(matroot,'fig4.pdf'),'-dpdf');
































