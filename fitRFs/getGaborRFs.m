% return receptive fields
function [cRF,rfstats] = getGaborRFs(X, A, gbest, crat, yx)

A1 = A(:,gbest(~isnan(gbest)));
A1 = cat(1, A1, yx(~isnan(gbest),:)');

gb = gaborReduced(A1,X);
cRF = gather_try(gb);

rfstats  = NaN*zeros(size(A1),'single');
rfstats(:,~isnan(gbest)) = gather_try(A1);
rfstats(end+1,:) = crat;
