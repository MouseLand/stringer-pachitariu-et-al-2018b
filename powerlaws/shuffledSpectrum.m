function [specS,cproj,specN] = shuffledSpectrum(respB0, nsh,useGPU)

nstims = size(respB0,1);
fullCOV = reshape(permute(respB0,[1 3 2]),[],size(respB0,2)) * ...
    reshape(permute(respB0,[1 3 2]),[],size(respB0,2))';
if useGPU
	fullCOV = gpuArray(single(fullCOV));
	respB0=gpuArray(single(respB0));
	specS=gpuArray.zeros(nstims, nsh, 'single');
else
	specS=zeros(nstims, nsh, 'single');
end
clear respBz;
for ish = 1:nsh
    
    respBz = respB0;
	% shuffle stimuli from first and second repeat
    if nsh > 1
        inr = rand(size(respB0,1),1) < .5;
    else
        inr = false(size(respB0,1),1);
    end
    respBz(inr,:,:) = respB0(inr,:,[2 1]);
    istims1 = Inf*ones(nstims,1);
    istims1(~inr) = find(~inr);
    istims2 = Inf*ones(nstims,1);
    istims2(inr) = find(inr);
    
    [~,istims] = sort([istims1; istims2],'ascend');
    
    istims = istims(1:nstims);
    
    [A, B, C] = svd(fullCOV(istims, istims));
    
	clear cproj
    cproj(:,:,1) = respBz(:,:,1) * (respBz(:,:,1)' * A / diag(sqrt(diag(B))));
    cproj(:,:,2) = respBz(:,:,2) * (respBz(:,:,1)' * A / diag(sqrt(diag(B))));
    
    Nd = size(cproj,1) * size(cproj,2);
    ss = sum(cproj(:,:,1).*cproj(:,:,2), 1);
	
	totV = sum(cproj(:,:,1).^2) + sum(cproj(:,:,2).^2);
	ns = totV - ss;
	
    specS(:,ish) = ss;
	specN(:,ish) = ns;

end