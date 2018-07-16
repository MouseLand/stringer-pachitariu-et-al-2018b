function [ycent, xcent] = estimateRFs(imgs, rtrain)

[Ly, Lx, nimg] = size(imgs);

% estimate receptive fields

[xs,ys] = ndgrid([1:Ly], [1:Lx]);
clear X;
X(:,1)  = ys(:);
X(:,2)  = xs(:);

fspat = .01;
spat = 10;
sratio = 1;
ori = 0;
phase = 0;

clear A;
A(6,:) = ys(:);
A(7,:) = xs(:);
A(1,:) = fspat;
A(2,:) = spat;
A(3,:) = sratio;
A(4,:) = ori;
A(5,:) = phase;
A = gpuArray(single(A));
X = gpuArray(single(X));

% gabors at each pixel location
gb = gaborReduced(A,X);

imgs   = reshape(imgs, [], nimg);
respGB = gb' * imgs;
respGB = gather(respGB);

cc = corr(respGB', rtrain);        
[~,ip] = max(abs(cc),[],1);

ycent = ys(ip);
xcent = xs(ip);

%%
clf;
[yxdist,yed,xed] = histcounts2(ycent, xcent, 30);

imagesc(yed,xed,yxdist');
colormap('jet');
xlabel('x (degrees)');
ylabel('y (degrees)');
axis image;
