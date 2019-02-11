
[theta,phi] = meshgrid([0:.05:2*pi], [0:.05:pi]);
r = ones(size(theta));
[x,y,z] = sph2cart(theta, phi-pi/2, r);

%%
clf;
k=0;
for l = 5:40
	for m=5
		k=k+1;
		my_subplot(6,6,k);
		[Ymn,THETA,PHI,X,Y,Z] = spharm(l, m, size(theta'), 0);
		%y = yml(m,l,theta,phi);
		surface(x,y,z,real(Ymn), 'EdgeColor','none');
		view(-10,25);
		axis square;
		axis off;
		colormap('redblue');
		%colormap(flipud(cmap))
	end
end

function y = yml(m,l,theta,phi)

p = Pml(m, l, cos(phi));

y = p .* cos(m * theta);

end

function p = Pml(m, l, x)

p = legendre(l, x);
p = squeeze(p(m+1, :, :));

end