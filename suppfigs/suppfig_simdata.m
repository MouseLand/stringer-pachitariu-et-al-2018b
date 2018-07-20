% simulate random data with power-law eigenspectra and evaluate
% cross-validated PCA analysis
function suppfig_simdata(matroot)

load(fullfile(matroot,'simSpectrum.mat'));

%%
close all;
default_figure([1 1 6 2]);
%%
xh = .65;
yh = .65;
clf;
i=0;
cm = colormap('winter');
cm = cm(1:12:end,:);
i=i+1;
hs{i}=my_subplot(1,3,1,[xh yh]);
ip0 = 3;
for k = 1:size(specSim,2)
    %ss = nanmean(specSim(:,k,:,ip0),3);
    ss = specSim(:,k,4,ip0);
    loglog(ss / sum(ss),'color',cm(k,:));
    hold all;
    text(.9,1-(k-1)*.12,[sprintf('%1.0f',nanmean(100*Vx(:,k,1,ip0)))],'color',cm(k,:),'fontsize',8,'HorizontalAlignment','right');
end
text(.7,1,'% stim variance: ','fontsize',8,'HorizontalAlignment','right');
box off;
grid on;
grid minor;
grid minor;
xlabel('dimensions');
ylabel('variance');
axis square;
axis([1 2800 2e-5 1]);
set(gca,'ytick',10.^[-6:2:0]);

i=i+1;
hs{i}=my_subplot(1,3,2,[xh yh]);
hold all;
asim = [];
for ip0 = 2
    for k = 1:size(specSim,2)
        for j = 1:size(specSim,3)
            asim(k,j) = get_powerlaw(specSim(:,k,j,ip0),[20:500]);
        end
        if k > 1
            errorbar(nanmean(nanmean(Vx(:,k,:,ip0)*100,1),3),nanmean(asim(k,:),2),nanstd(asim(k,:),1,2),...
                '.','color',cm(k,:),'markersize',10,'linewidth',1.5);
        else
            plot([0 .4*100],[1 1]*asim(1,1),'k');
        end
    end
end
box off;
xlabel('% stim-related variance');
ylabel('power law exponent \alpha');
axis square;
ylim([0.97 1.03])
set(gca,'xtick',[0:10:40]);

i=i+1;
hs{i}=my_subplot(1,3,3,[xh yh]);
hold all;
asim = [];
for ip0 = 1:3
for k = 1:size(specSim,2)
    for j = 1:size(specSim,3)
        asim(k,j) = get_powerlaw(specSim(:,k,j,ip0),[20:500]);
    end
    if k > 1
        errorbar(nanmean(nanmean(Vx(:,k,:,ip0)*100,1),3),nanmean(asim(k,:),2),nanstd(asim(k,:),1,2),...
            '.','color',cm(k,:),'markersize',10,'linewidth',1.5);
    else
        plot([0 40],[1 1]*asim(1,1),'k');
    end
end
end
box off;
xlabel('% stim-related variance');
ylabel('power law exponent \alpha');
axis square;
%ylim([0.95 1.03])


%%

tstr = {{'simulated spectrum w/ noise'},'average simulated \alpha','average simulated \alpha'};

for j = 1:length(hs)
    axes('position',hs{j}.Position);
    axis off;
    text(-.3,1.2,char(96+j),'fontsize',12,'fontweight','bold');
    %text(-.2,1.15,tstr{j},'fontsize',8);
    
end

%%
print('fig/supp_sims.pdf','-dpdf');