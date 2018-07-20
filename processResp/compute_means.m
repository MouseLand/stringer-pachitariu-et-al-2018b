% splits stimulus responses into nsplits and computes mean of responses in
% each split. if interleaved then the responses are interleaved in time,
% otherwise, split happens in the middle of the responses temporally
% (resp is in stimulus presentation order)
function [A, Asem] = compute_means(istim, resp1, nsplits, interleaved)

[Ntrials NN] = size(resp1);
nimg = max(istim);
A = NaN * ones(nimg, NN, nsplits);
Asem = NaN * ones(nimg, NN, nsplits);

for i = 1:nimg
    this_stim = find(istim'==i);
    
    for k = 1:nsplits
        if exist('interleaved', 'var') && interleaved==1
            inds = k:nsplits:numel(this_stim);
        else
            inds = ceil(numel(this_stim) * (k-1)/nsplits)+[1:floor(numel(this_stim)/nsplits)];
        end
        
        A(i, :, k) = mean(resp1(this_stim(inds), :), 1);
        
        if nargout>1
            Asem(i, :, k)= std(resp1(this_stim(inds), :), [], 1)/sqrt(numel(inds)-1);
        end
    end    
end
