% return receptive fields
function [cRF] = plotLowRankRFs(Ly, Lx, a, b, C)

rfN = b(:,:) * a(:,:)';
cRF = rfN * C';
cRF = reshape(cRF, Ly, Lx, size(cRF,2));