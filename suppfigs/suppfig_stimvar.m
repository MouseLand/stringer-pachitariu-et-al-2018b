% plot of signal variance and example neuron response
function suppfig_stimvar(matroot)
load(fullfile(matroot, 'natimg2800_proc.mat'))
load(fullfile(matroot, 'eigs_and_stats_all.mat'));

close all;
HF=default_figure([10 1 4 3]);
%%
clf;
d = 6;
% -----------EXAMPLE NEURON-------------------------------------------
hs=my_subplot(2,2,1,[.7 .6]);
hs.Position(2) = hs.Position(2) - .03;
[~,ix] = sort(Vx{1}{d},'descend');
neur = ix(2);
cc   = Vx{1}{d}(neur);
R = respAll{d};
plot(R(:,neur,1), R(:,neur,2), '.', 'MarkerSize', 1)
hold all;
p = polyfit(R(:,neur,1),R(:,neur,2),1);
ypred = p(1)*R(:,neur,1) + p(2);
plot(R(:,neur,1),ypred,'r');
axis tight;
box off
text(0.05, .85, sprintf('r=%2.2f', cc), 'Fontsize', 8, 'Fontweight', 'bold', 'horizontalalignment', 'left')
text(0.05, 1, 'p<1e-50', 'Fontsize', 8, 'Fontweight', 'bold', 'horizontalalignment', 'left')
text(-.2, 1.1, 'Responses of one cell', 'verticalalign', 'bottom')
xlabel('repeat 1')
ylabel('repeat 2')
text(-.5, 1.3, 'a', 'Fontweight', 'bold', 'Fontangle', 'normal', 'Units', 'normalized', 'verticalAlignment', 'top', 'Fontsize', 12);
axis square 

% -------PVALS ---------------------------------------------------------
col = colormap('parula');
col = col(round(linspace(1,56, numel(Px{1}))), :);
icol = randperm(numel(Px{1}));
hs=my_subplot(2,2,2,[.7 .6]);
hs.Position(2) = hs.Position(2) - .03;
bins = [0:.005:1];
for j = 1:numel(Px{1})
	histogram(Px{1}{j},bins, 'EdgeColor', col(icol(k), :), 'DisplayStyle', 'stairs', 'Linewidth', 1);
    hold all;
end
set(gca,'XScale','log');
xlabel('p value')
ylabel('fraction')
text(1, 1, 'p = .05', 'horizontalalignment', 'right','Fontweight', 'bold', 'Fontangle', 'normal', 'Fontsize', 8)
box off
text(-.3, 1.3, 'b', 'Fontweight', 'bold', 'Fontangle', 'normal', 'Units', 'normalized', 'verticalAlignment', 'top', 'Fontsize', 12);
text(-.1, 1.1, 'Tuning significance', 'verticalalign', 'bottom')
axis square 
hold on
plot([.05 .05], [0 .05], 'k')
hold off
axis tight

% --------CORRELATIONS------------------------------------------------
hs=my_subplot(2,1,2);
bins = [0:.005:.6];
for k = 1:numel(Vx{1})
	histogram(Vx{1}{k}*100, bins*100, 'EdgeColor', col(icol(k), :), 'DisplayStyle', 'stairs', 'Linewidth', 1)
	hold on
	plot(nanmean(Vx{1}{k}*100), 700,'v','color',col(icol(k),:));
end
axis tight;
box off;
ylabel('number of cells');
xlabel('% stimulus-related variance');
ncells = sum(cellfun(@(x) numel(x), snr{1}));
for k = 1:numel(snr{1})
	if k == 1
		text(.6, 1.1 - .1*k, sprintf('N = %d neurons', numel(snr{1}{k})),...
			'Color', col(icol(k),:), 'Fontangle', 'normal', 'Fontsize', 6);
	else
		text(.6, 1.1 - .1*k, sprintf('N = %d', numel(snr{1}{k})),...
			'Color', col(icol(k),:), 'Fontangle', 'normal', 'Fontsize', 6);
	end
end
text(-.2,1.1,'c', 'Fontweight', 'bold', 'Fontangle', 'normal', 'Units', 'normalized', 'verticalAlignment', 'top', 'Fontsize', 12);

%%
print('fig/supp_stimvar.pdf','-dpdf');

