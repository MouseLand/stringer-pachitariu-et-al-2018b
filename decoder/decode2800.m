clear all;

matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp/';


load(fullfile(dataroot,'natimg2800Proc.mat'));

%%

clear pCorrect nStims nNeu;

nn = 2.^[13:-1:0];

nNeu = NaN*size(length(nn)+1,length(respAll));
for ip = 1:length(respAll) 
    
    r1 = respAll{ip}(:, :, 1);
    r2 = respAll{ip}(:, :, 2);
        
    r1 = zscore(r1, 1,1);
    r2 = zscore(r2, 1,1);
        
    NN = size(r1,2);
    
    nStims(ip) = size(r1,1);
    nNeu(2:length(nn)+1,ip) = nn;
    nNeu(1,ip)          = NN;
        
    rng(1);
    rperm = randperm(NN);

    for k = 1:size(nNeu,1)
        r10 = r1(:, rperm(1:nNeu(k,ip)));
        r20 = r2(:, rperm(1:nNeu(k,ip)));
        CC = corr(r10', r20');
        [~, imax] = max(CC, [], 1);
        pCorrect(k,ip) = nanmean(imax == [1:numel(imax)]);
    end
    
end

save(fullfile(matroot, 'decoder2800.mat'),'pCorrect','nNeu');