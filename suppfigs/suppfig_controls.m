matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/'

load(fullfile(matroot, 'controlSpecs.mat'));
load(fullfile(matroot, 'specSpontPC.mat'));
load(fullfile(matroot, 'eigsAllStats.mat'));

%%
close all;
default_figure([10 1 6 4]);

%%
clf;
nD = length(specZ);
lam = NaN*ones(2800,nD);
for k = 1:nD
    lam(1:numel(specS{1}{k}),k) = specS{1}{k};
end

specA = nanmean(lam,2);
alpA = get_powerlaw(specA,[11:500]);

cm = colormap('parula');
cm = cm(1:9:end,:);
cs = colormap('spring');
cs = cs(1:10:end,:);
lam = NaN*ones(2800,nD,6);%numel(nPCspont));
for k = 1:nD
    for j = 1:6%numel(specPC{k})
        lam(1:numel(specPC{k}{j}),k,j) = specPC{k}{j};
    end
end
sPCA = squeeze(nanmean(lam,2));
sPCA = num2cell(sPCA,1);
clear hs;
tstr = {'Single neuron variance','Single neuron variance (z-scored)','PC variance (z-scored)',...
	'Example recording','Averaged'};
for j = 1:5
    hs{j}=my_subplot(2,3,j,[.6 .6]);
    switch j
        case 1
            ss = sigVar;
        case 3
			ss = specZ;
        case 2
			ss = specVar;
		case 4
            ss = specPC{2};
        case 5
            ss = sPCA;
    end
    lam = NaN*ones(2800,numel(ss));
    for k = 1:numel(ss)
        if j<4
            ck = cm(k,:);
        else
            ck = cs(k,:);
        end
        loglog(ss{k},'linewidth',0.5,'color',ck)
        lam(1:numel(ss{k}),k) = ss{k};
        hold all;
        if j>3
            
            text(.9,1.1-.1*k,num2str(nPCspont(k)),'color',ck,'fontsize',8);
            if k == 1
				text(.3,1.,{'spont PCs','subtracted:'},'fontsize',8);
			end
        end
    end
    [alp,ypred] = get_powerlaw(nanmean(lam,2),[11:500]);
    if j<4
        plot(ypred,'k','linewidth',1.5);
        text(.15,.45,sprintf('\\alpha=%1.2f',alp),'color','k','fontsize',8);
    end
    
    if j==3
        loglog(specA,'b--','linewidth',2);
        text(.5,.95,sprintf('original\n\\alpha=%1.2f',alpA),'color','b','fontsize',8);
    end
    
    
    box off;
    axis square;
	axis tight;
    %if j~=4
        %axis([1 2800 5e-5 .1]);
        xlabel('PC dimension');
        ylabel('variance');
		if j==1 || j==2
			xlabel('neurons');
			ylabel('signal variance');
        else
            ylim([1e-5 0.1]);
   
		end
    %else
    %    xlabel('neurons');
    %    ylabel({'%'});
    %    axis([1 1.4e4 1e-3 1]);
    %    set(gca,'xtick',10.^[0:4],'ytick',[.01 .1 1],'yticklabel',{'1','10','100'});
    %end
    
    text(-.4,1.25,char(96+j),'fontsize',12,'fontweight','bold');
    text(-.25,1.2,tstr{j},'fontsize',8);
end
% 
% hs{9}=my_subplot(3,3,9,[.6 .6]);
% for k = 1:7
% 	smean = cellfun(@nanmean,snr{k});
% 	plot(nPCspont(1:6),smean(1:6),'color',cm(k,:));
% 	hold all;
% 	
% end
% box off;
% axis square;
% 

%%
print('../figs/suppControlnew.pdf','-dpdf');
