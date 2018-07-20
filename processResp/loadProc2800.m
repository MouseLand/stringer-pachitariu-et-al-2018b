% computes normalized stimulus responses and divides them into two halves
% nPCspont is how many spont PCs to subtract
% keepNAN is whether or not to keep stimuli that weren't repeated twice
% (they will be nan's in the matrix, default is 0)
% stimorder is the temporal order of the stimuli
function [respBz, istim] = loadProc2800(stim, nPCspont, keepNAN, useGPU)

nimg = max(stim.istim)-1;

resp0   = stim.resp(stim.istim<=nimg, :);
resp0(isnan(resp0)) = 0;
istim = stim.istim(stim.istim<=nimg);

if ~isempty(stim.spont)
    mu      = mean(stim.spont,1);
    sd      = std(stim.spont,1,1)+ 1e-6;
else
    mu      = mean(resp0,1);
    sd      = std(resp0,1,1)+ 1e-6;
end
resp0   = (resp0 - mu)./sd;

% subtract spont
if nPCspont > 0 && ~isempty(stim.spont)
    Fs0 = stim.spont;
    Fs0 = (Fs0 - mu)./sd;
	if useGPU
		Fs0 = gpuArray(single(Fs0));
	end
    [~, ~, Vspont] = svdecon(single(Fs0));
    Vspont = gather_try(Vspont(:, 1:nPCspont));
    resp0 = resp0 - (resp0 * Vspont) * Vspont';
end

% mean center each neuron's responses
resp0 = resp0 - mean(resp0, 1);

% split stimulus responses into two repeats
respB = compute_means(istim, resp0, 2, 0);
iNotNaN = ~isnan(sum(respB(:,:),2));
istim = find(iNotNaN);

respBz = respB;
if ~(nargin>5 && keepNAN)
    respBz = respBz(iNotNaN, :, :);
end


