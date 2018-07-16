% return receptive fields
function [cRF] = plotGaborRFs(Ly, Lx, rfstats)

[ys,xs] = ndgrid([1:Ly], [1:Lx]);
clear X;
X(:,1)  = ys(:);
X(:,2)  = xs(:);

%C = rfstats(:,wbest==1);
%C = C([1:4 6:7],:);

%cs = centersurround(C,X);

A =  rfstats(1:end-1,:);
cRF = gaborReduced(A,X);

cRF = reshape(cRF, Ly, Lx, size(cRF,2));
