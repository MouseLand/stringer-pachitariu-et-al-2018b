np = 2^12;
theta = linspace(0,2*pi,np);
nD = 200000; % number of dimensions

% a random projection w
rng(3);
w = randn(3,nD);

alp = [4.0:-.02:2.0];
%alp = [2.0];
na = length(alp);
F(na) = struct('cdata',[],'colormap',[]);

for k = 1:na
	px = zeros(nD,np);
	% sines and cosines with decay alp(k)
	theta = linspace(0,2*pi,np);
	x = zeros(nD,np);
	nn = zeros(nD,1);
	for n = 1:nD/2
		x((n-1)*2+1,:) = cos(theta*n);
		x((n)*2,:) = sin(theta*n);
		nn((n-1)*2+1) = n;
		nn((n)*2) = n;
	end
	px = x .* nn(:).^(-alp(k)/2);
	
	wproj = w * (px ./ sum(px.^2,1).^.5);
	clf;
	plot3(wproj(1,:),wproj(2,:),zeros(1,np)-3.5,'color',.7*[1 1 1],'linewidth',1);
	grid on;
	hold all;
	plot3(wproj(1,:),wproj(2,:),wproj(3,:),'k','linewidth',1);
	
	axis([-2.5 2.2 -2.5 2.2 -2.5 2.2]);
	title(sprintf('\\alpha = %1.2f',alp(k)),'fontsize',16)
	drawnow;
	F(k)=getframe(gcf);
	%pause(.1)
	
end

%%
v = VideoWriter('fractal.avi');
v.FrameRate = 10;
open(v);
for k = 1:na
	v.writeVideo(F(k).cdata);
end
close(v);
