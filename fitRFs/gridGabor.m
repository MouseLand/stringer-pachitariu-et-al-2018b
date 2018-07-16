function [A,X] = gridGabor(Ly,Lx,fspat,spat,sratio,ori,phase)

[ys,xs] = ndgrid([1:Ly], [1:Lx]);
clear X;
X(:,1)  = ys(:);
X(:,2)  = xs(:);

[s1,s2,s3,s4,s5] = ndgrid(fspat, spat, sratio, ori, phase);
clear A;
A(1,:) = s1(:);
A(2,:) = s2(:);
A(3,:) = s3(:);
A(4,:) = s4(:);
A(5,:) = s5(:);

