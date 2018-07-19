

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
