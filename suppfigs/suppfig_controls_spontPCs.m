function suppfig_controls_spontPCs(matroot)

load(fullfile(matroot, 'zscored_spectrum.mat'));
load(fullfile(matroot, 'spontPC_spectrum.mat'));
load(fullfile(matroot, 'eigs_and_stats_all.mat'));

%%
close all;
default_figure([10 1 6 2]);

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
for j = 1:3
    hs{j}=my_subplot(1,3,j,[.6 .6]);
    switch j
        case 1
            ss = sigVar;
        case 2
			ss = specVar;
		case 3
			ss = specZ;
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
	plot(ypred,'k','linewidth',1.5);
	text(.15,.45,sprintf('\\alpha=%1.2f',alp),'color','k','fontsize',8);
    if j==3
        loglog(specA,'b--','linewidth',2);
        text(.5,.95,sprintf('original\n\\alpha=%1.2f',alpA),'color','b','fontsize',8);
    end
    
    
    box off;
    axis square;
	axis tight;
    
	xlabel('PC dimension');
    ylabel('variance');
	if j==1 || j==2
		xlabel('neurons');
		ylabel('signal variance');
	else
		ylim([1e-5 0.1]);
	end
	
    text(-.4,1.25,char(96+j),'fontsize',12,'fontweight','bold');
    text(-.25,1.2,tstr{j},'fontsize',8);
end

print('fig/supp_controls.pdf','-dpdf');

%% spont PC analysis

close all;
default_figure([10 1 4 2]);
tstr = {'Example recording','Averaged'};
for j = 1:2
    hs{j}=my_subplot(1,2,j,[.6 .6]);
	if j == 1
        ss = specPC{2};
	else
		ss = sPCA;
	end
    lam = NaN*ones(2800,numel(ss));
    for k = 1:numel(ss)
		ck = cs(k,:);
        loglog(ss{k},'linewidth',0.5,'color',ck)
        lam(1:numel(ss{k}),k) = ss{k};
        hold all;
		text(1,1.1-.1*k,num2str(nPCspont(k)),'color',ck,'fontsize',8);
		if k == 1
			text(.42,1.1,{'spont PCs','subtracted:'},'fontsize',8);
		end
    end
    %[alp,ypred] = get_powerlaw(nanmean(lam,2),[11:500]);
    box off;
    axis square;
	axis tight;
    
	xlabel('PC dimension');
    ylabel('variance');
	if j==1 || j==2
		xlabel('neurons');
		ylabel('signal variance');
	else
		ylim([1e-5 0.1]);
	end
	
    text(-.4,1.25,char(96+j),'fontsize',12,'fontweight','bold');
    text(-.25,1.2,tstr{j},'fontsize',8);
end

print('fig/supp_spontPCs.pdf','-dpdf');






















