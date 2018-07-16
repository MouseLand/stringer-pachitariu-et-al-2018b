%%%% computes linear fit to ss from ss(trange0)
% alpha is slope of linear fit
% ypred is linear fit across full support of ss
% b is y-intercept
% r is correlation in log-log space of ss with linear fit
function [alpha, ypred, b, r] = get_powerlaw(ss, trange0)

allrange = 1:numel(ss);

logss = log(abs(ss(:)));
Y = logss(trange0)';

NT = numel(Y);
X = -log(trange0)';
w = 1./trange0(:);

X = [X ones(NT,1)];
B = (Y*(w.*X))/(X'*(w.*X));

lpts = round(exp(linspace(log(trange0(1)),log(trange0(end)),100)));

r     = corr(log(lpts(:)), logss(lpts(:)));
r     = r^2;

X = [-log(allrange)' ones(numel(allrange),1)];

ypred = exp(X * B(:));

alpha = B(1);
b = B(2);

