function suppfig_ephys_powerlaw(matroot)

load('fig/ephys_eigsControls.mat');
single = load(fullfile(matroot, 'eigsControls_natimg2800_ephys.mat'));
conc = load(fullfile(matroot, 'eigsControls_natimg2800_ephys_concatenate.mat'));

%%
close all;
default_figure([1,1,6,3]);
%%

clf;
clear hs;
hs{1}=subplot(1,2,1);
shadedErrorBar([1:700],mean(single.specS,2),std(single.specS,1,2)/sqrt(6),{'color','b'});
hold all;
shadedErrorBar([1:700],mean(conc.specS,2),std(conc.specS,1,2)/sqrt(9),...
	{'color',[.5 .7 1]});
hold all;
%plot(ypred,'k');
set(gca,'XScale','log')
set(gca,'YScale','log')
plot([1:700],specEphys{end,1},'r--');
[a0,ypred]=get_powerlaw(specEphys{end,1},[10:500]);
plot([1:700],ypred,'r');
plot([1:700],specEphys{end,2},'--','color',[1 .5 .5]);
text(.55,.7,sprintf('\\alpha=%2.2f',a0),'fontweight','bold','color','r');
%plot(ypred,'r');
text(.03,.5,'ephys (50 ms)','color','r','fontangle','normal');
text(.03,.4,'ephys (500 ms)','color',[1 .5 .5],'fontangle','normal');
text(.03,.3,'2P single recording','color','b','fontangle','normal');
text(.03,.2,{'2P all recordings','(combined)'},'color',[0.5 .7 1],'fontangle','normal');
xlabel('PC dimension');
ylabel('variance');
text(0.2,1.15,{'n_{neurons} = 877','n_{stimuli} = 700'},'fontweight','normal')
box off;
ylim([1e-5 0.3]);
set(gca,'fontsize',8)
axis('square')


hs{2}=subplot(1,2,2);
shadedErrorBar(single.nneur,mean(single.alpha,2),std(single.alpha,1,2)/sqrt(6),{'color','b'});
hold all;
shadedErrorBar(single.nneur,mean(conc.alpha,2),std(conc.alpha,1,2)/sqrt(9),...
	{'color',[.5 .7 1]});
plot(nneurEphys(end),alphaEphys(end,1),'rx','markersize',14,'linewidth',2);
plot(nneurEphys(end),alphaEphys(end,2),'x','color',[1 .5 .5],'markersize',14,'linewidth',2);
text(.02,.35,'ephys (50 ms)','color','r','fontangle','normal');
text(.02,.25,'ephys (500 ms)','color',[1 .5 .5],'fontangle','normal');
text(.3,.85,'2P single recording','color','b','fontangle','normal');
text(.4,.75,{'2P all recordings','(combined)'},'color',[0.5 .7 1],'fontangle','normal');
text(0.2,1.1,{'n_{stimuli} = 700'},'fontweight','normal')
xlabel('number of neurons');
ylabel('power law exponent (\alpha)');
box off;
set(gca,'fontsize',8,'xscale','log')
axis('square')

for j = 1:2
	axes('position',hs{j}.Position);
	axis off;
	text(-.2,1.05,char(96+j),'fontsize',12,'fontweight','bold');
	
end

%%
print('fig/suppEphysAlpha.pdf','-dpdf');
