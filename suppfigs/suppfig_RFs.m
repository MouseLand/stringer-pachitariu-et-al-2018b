%% LOW RANK RECEPTIVE FIELD FIGURE!
function suppfig_RFs(matroot)

lr = load(fullfile(matroot,'lowrank_fits.mat'));

% choose example dataset and compute RFs for plot
d = 5;
[~, isort] = sort(lr.vtest{d}, 'descend');
% low-rank RFs
[lrRF] = plotLowRankRFs(68, 270, lr.aAll{d}, lr.bAll{d}, lr.cAll{d});


close all;
default_figure([10 1 10 10]);

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
print(fullfile(matroot,'supp_RFs.pdf'),'-dpdf','-bestfit');
