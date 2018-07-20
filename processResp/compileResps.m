% compute two repeats from sequence of stimuli and responses
% subtracts spontaneous components (nPCspont)
function compileResps(dataroot, matroot, useGPU)

%% contains information about recordings
load(fullfile(dataroot,'dbstims.mat'));

for K = 1:6
    clf;
    iexp = find(stype==K);
    clear respAll;
    for k = 1:length(iexp)
        fname = fullfile(dataroot, sprintf('%s_%s_%s.mat', stimset{K},...
            dbstims(iexp(k)).mouse_name, dbstims(iexp(k)).date));
		% load data
        dat = load(fname);
		% discard responses from red cells (GAD+ neurons)
		stim = dat.stim;
		if isfield(dat.stat,'redcell')
			stim = dat.stim;
			stim.resp = stim.resp(:, ~[dat.stat.redcell]);%
			stim.spont = stim.spont(:, ~[dat.stat.redcell]);
			%sum(~[dat.stat.redcell])
		else
			stim = dat.stim;
		end
		
        nPCspont = 32;
        keepNAN = 0;
        [respB,wstim] = loadProc2800(stim, nPCspont, keepNAN, useGPU);
        
        fprintf('%s_%s_%s.mat processed\n', stimset{K},...
            dbstims(iexp(k)).mouse_name, dbstims(iexp(k)).date)
        respAll{k}  = single(respB);
        istimAll{k} = single(wstim);
    end
    save(fullfile(matroot, sprintf('%s_proc.mat', stimset{K})),'respAll','istimAll');
end
