clear all;

useGPU = 1;
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp';
matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';        

load(fullfile(dataroot,'dbstims.mat'));

%%
nstims = 2800;
nPCspont = 0;

clear specS;

clf;
%clear p;
for K = 1:6
    clf;
    load(fullfile(dataroot,sprintf('%sProc.mat',stimset{K})));
    clear specS;
    ik=0;
    for iexp = find(stype==K)
        ik = ik+1;
        disp(ik)
        respBz = respAll{ik};
        
        sperm = randperm(size(respBz,1));
        nperm = randperm(size(respBz,2));
        
        nr      = ceil(numel(nperm) * 2.^[0:-1:-7]);
        sr      = ceil(numel(sperm) * 2.^[0:-1:-7]);
        
        NumNeu(ik) = size(respBz,2);
        
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
                respSub = gpuArray(respSub);
               
                nshuff = 10;
                ss = shuffledSpectrum(respSub, nshuff, useGPU);
                ss = gather(nanmean(ss,2));
                ss = ss(:) / sum(ss);
                specS{k,j}(1:numel(ss), ik) = ss;
                disp([nr0 sr0]);
            end
        end
        specS
    end
    
    %%
    save(fullfile(matroot,sprintf('eigsControls_%s.mat',stimset{K})), 'specS', 'NumNeu')
        
end