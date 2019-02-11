% compute cross-validated PCs for varying numbers of neurons and stimuli
function incNeurStimPowerLaw(dataroot, matroot)

load(fullfile(dataroot,'dbstims.mat'));
%%
for K = 1:6
    clf;
    load(fullfile(matroot,sprintf('%s_proc.mat',stimset{K})));
    clear specS;
    iexp = find(stype==K);
	NumNeur = [];
    for ik = 1:length(iexp)
        respBz = double(respAll{ik});
        
        sperm = randperm(size(respBz,1));
        nperm = randperm(size(respBz,2));
        
        nr      = ceil(numel(nperm) * 2.^[0:-1:-7]);
        sr      = ceil(numel(sperm) * 2.^[0:-1:-7]);
        
        NumNeur(ik) = size(respBz,2);
        
        for j = 1:2
            for k = 1:numel(nr)
                if ik == 1
                    specS{k,j} = NaN * ones(2800, sum(stype==K));
                end
                if j == 1
                    sr0 = sr(1);
                    nr0 = nr(k);
                else
                    sr0 = sr(k);
                    nr0 = nr(1);
                end
                respSub = respBz(sperm(1:sr0),nperm(1:nr0),:);
                
                nshuff = 10;
                ss = shuffledSpectrum(respSub, nshuff);
                ss = gather_try(nanmean(ss,2));
                ss = ss(:) / sum(ss);
                specS{k,j}(1:numel(ss), ik) = ss;
                fprintf('%s %d neur %d stim %d \n', stimset{K}, ik, nr0, sr0);
            end
		end
    end
    
    %%
    save(fullfile(matroot,sprintf('eigs_incneurstim_%s.mat',stimset{K})), 'specS', 'NumNeur')
        
end