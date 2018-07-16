function [respBz, istim] = loadProc2800(stim, nPCspont, keepNAN)

resp0   = stim.resp(stim.istim<max(stim.istim), :);
resp0(isnan(resp0)) = 0;
istim = stim.istim(stim.istim<max(stim.istim));


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
    %Fs0 = my_conv2(Fs0, 1, 1);
    [~, ~, Vspont] = svdecon(gpuArray(single(Fs0)));
    Vspont = gather(Vspont(:, 1:nPCspont));
    resp0 = resp0 - (resp0 * Vspont) * Vspont';
end

resp0 = resp0 - mean(resp0, 1);

respB = compute_means(istim, resp0, 2, 0);
iNotNaN = ~isnan(sum(respB(:,:),2));

istim = find(iNotNaN);

respBz = respB;
if ~(nargin>5 && keepNAN)
    respBz = respBz(iNotNaN, :, :);
end

stim.respB = respBz;

