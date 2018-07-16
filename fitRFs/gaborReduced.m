%%% computes gabor filters, takes
% A: parameters x ngabors
% (parameters: spatial frequency, size, X/Y ratio, orientation, phase)
% X: X(:,1) <- x coords, X(:,2) <- y coords (output of meshgrid)
% outputs
% F: X x ngabors

function F = gaborReduced(A, X)
x = X(:,1);
y = X(:,2);

f       = A(1,:);
sigma1  = A(2,:);
sigma2  = A(2,:) .* A(3,:);
theta   = A(4,:);
psi     = A(5,:);
M       = 1;

if size(A,1) < 6
   x0      = 0;
   y0      = 0;
else
    x0 = A(6,:);
    y0 = A(7,:);
end

N = size(A,2);
Npix = size(X,1);

xp = (x * ones(1,N) - ones(Npix,1) * x0) .* (ones(Npix,1) * cos(theta)) + ...
    (y * ones(1,N) - ones(Npix,1) * y0) .* (ones(Npix,1) * sin(theta));
yp = -(x * ones(1,N) - ones(Npix,1) * x0) .* (ones(Npix,1) * sin(theta)) + ...
    (y * ones(1,N) - ones(Npix,1) * y0) .* (ones(Npix,1) * cos(theta));

F = (ones(Npix,1) * M) .* exp(- 1/2 * (xp.^2./(ones(Npix,1)*sigma1).^2 + ...
    yp.^2./(ones(Npix,1)*sigma2).^2)) ...
    .* cos(2 * pi * (ones(Npix,1) * f) .* xp + ones(Npix,1) * psi);
end
