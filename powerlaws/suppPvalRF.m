%% PVALUE FIGURE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

np = cellfun(@(x) mean(x<.05),Px{1});

close all;
HF=default_figure([10 1 4 3]);
%%
clf;
% ------------------------------------------------------------------------
%axes('Position',[.1 .35 .13 .12]);
hs=my_subplot(2,2,1,[.7 .6]);
hs.Position(2) = hs.Position(2) - .03;
[~,ix] = sort(Vx{1}{d},'descend');
nU = ix(2);

pall = Px{1}{d};
cc   = Vx{1}{d}(nU);

plot(R0(:,nU,1), R0(:,nU,2), '.', 'MarkerSize', 1)
axis tight;
%ylim([-2.2 7])
%xlim([-2.2 7])
box off
text(1, .85, sprintf('r=%2.2f', cc), 'Fontsize', 8, 'Fontweight', 'bold', 'horizontalalignment', 'right')
text(1, 1, 'p<1e-50', 'Fontsize', 8, 'Fontweight', 'bold', 'horizontalalignment', 'right')

text(-.2, 1.1, 'Responses of one cell', 'verticalalign', 'bottom')

xlabel('repeat 1')
ylabel('repeat 2')
text(-.5, 1.3, 'a', 'Fontweight', 'bold', 'Fontangle', 'normal', 'Units', 'normalized', 'verticalAlignment', 'top', 'Fontsize', 12);
axis square 

col = colormap('parula');
col = col(round(linspace(1,56, numel(Px{1}))), :);
icol = randperm(numel(Px{1}));

% ------------------------------------------------------------------------
%axes('Position',[.3 .35 .13 .12]);
hs=my_subplot(2,2,2,[.7 .6]);
hs.Position(2) = hs.Position(2) - .03;
bins = [0:.005:1];
clear bb
for j = 1:numel(Px{1})
    bb(:,j) = hist((Px{1}{j}), bins);
    semilogx((bins), bb(:,j)/sum(bb(:,j)), 'Color', col(icol(j), :))
	%histogram(Px{1}{j},bins,'edgecolor',col(icol(j),:),'displaystyle','stairs','Normalization','probability',...
	%	'linewidth',1);
    hold all;
end
xlabel('p value')
ylabel('fraction')
text(.9, 1, 'p = .05', 'horizontalalignment', 'right','Fontweight', 'bold', 'Fontangle', 'normal', 'Fontsize', 8)
box off
text(-.3, 1.3, 'b', 'Fontweight', 'bold', 'Fontangle', 'normal', 'Units', 'normalized', 'verticalAlignment', 'top', 'Fontsize', 12);
text(-.1, 1.1, 'Tuning significance', 'verticalalign', 'bottom')
axis square 

hold on
plot([.05 .05], [0 .05], 'k')
hold off
axis tight
% ------------------------------------------------------------------------
%axes('Position',[.1 .17 .35 .12]);
my_subplot(2,1,2);
rng(101);
for i = 1:numel(Px{1})
    histogram(vexpALL{i}, linspace(-.05,0.6, 100), 'EdgeColor', col(icol(i), :), 'DisplayStyle', 'stairs', 'Linewidth', 1)
    hold on
end
box off
ylim([0 800])
xlim([-.1 .5])
xlabel('r = stimulus-related variance (single-trial)')
ylabel('cell counts')
xlim([-.05 .6])
text(-.2, 1.1, 'c', 'Fontweight', 'bold', 'Fontangle', 'normal', 'Units', 'normalized', 'verticalAlignment', 'top', 'Fontsize', 12);
ncells = sum(cellfun(@(x) numel(x), vexpALL));
for i = 1:numel(Px{1})
    text(.6, .95 - .07*i, sprintf('N = %d', numel(vexpALL{i})), 'Color', col(icol(i),:), 'Fontangle', 'normal', 'Fontsize', 6);
end
text(.54, .3, sprintf('total = %d', ncells), 'Fontangle', 'normal', 'Fontweight', 'bold','fontsize',8)
%%
print('../figs/suppPvalsnew.pdf','-dpdf');



%%  RECEPTIVE FIELD FIGURE!!!!!!!!!!!!!!!!!!!!!!!!!!!!
close all;
HF=figure('Position', [10 1 10 10]);
pos = get(HF,'Position');
set(HF,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3)*1.0, pos(4)*1.0])

%%
clf;

rng(201);
ineu = isort;

ncols = 10;
nrows = 40;
for i = 1:ncols
    for j = 1:nrows
        axes('Position',[.01 + (i-1)*.98/ncols .03 + (nrows-j)*.95/nrows .95/ncols .85/nrows]);
        A = lrRF(:,:,ineu(i + (j-1)*ncols));
        A = reshape(zscore(reshape(A,[],1),1,1),size(A,1),size(A,2));
        imagesc(A, [-1 1]*7)
        colormap(redblue)
        axis off
      
        if i==2 && j==1
            hc=colorbar;
            hc.Position(1)= .08;
            hc.Position(4)= .025;
        end
    end
    drawnow;
end
%%
print('../figs/suppfig1_RFs.pdf','-dpdf','-bestfit');
