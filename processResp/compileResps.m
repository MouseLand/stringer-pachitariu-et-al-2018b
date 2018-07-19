% compute two repeats from sequence of stimuli and responses
% subtracts spontaneous components (nPCspont)
function compileResps(dataroot, matroot, useGPU)

% contains information about recordings
load(fullfile(dataroot,'dbstims.mat'));

for K = 1:7
    clf;
    iexp = find(stype==K);
    clear respAll;
    for k = 1:length(iexp)
        fname = fullfile(dataroot, sprintf('%s_%s_%s.mat', stimset{K},...
            dbstims(iexp(k)).mouse_name, dbstims(iexp(k)).date));
        
        load(fname);
        
        nPCspont = 32;
        keepNAN = 0;
        [respB,wstim] = loadProc2800(stim, nPCspont, keepNAN, useGPU);
        stim.respB = respB;
		
        fprintf('%s_%s_%s.mat processed\n', stimset{K},...
            dbstims(iexp(k)).mouse_name, dbstims(iexp(k)).date)
        respAll{k}=single(stim.respB);
        istimAll{k} = single(wstim);
    end
    save(fullfile(dataroot, sprintf('%s_proc.mat', stimset{K})),'respAll','istimAll');
end
