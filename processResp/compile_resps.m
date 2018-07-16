% compute all stats

clear all;
load('../dbstims.mat');

% datapath
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp/';        

stimset={'natimg2800','white2800','natimg2800_8D','natimg2800_4D','natimg2800_small','ori','natimg32'};
%%

nstims = 2800;
clf;
%clear p;
for K = 1:6
    clf;
    k=0;
    clear respAll;
    for iexp = find(stype==K)
        k = k+1;
        fname = fullfile(dataroot, sprintf('%s_%s_%s.mat', stimset{K},...
            dbstims(iexp).mouse_name, dbstims(iexp).date));
        
        load(fname);
        
        nPCspont = 32;
        keepNAN = 0;
        [respB,wstim] = loadProc2800(stim, nPCspont, keepNAN);
        stim.respB = respB;
		
        disp(iexp)
        stim
        respAll{k}=single(stim.respB);
        istimAll{k} = single(wstim);
    end
    save(fullfile(dataroot, sprintf('%sProc.mat', stimset{K})),'respAll','istimAll');
end
