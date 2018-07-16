clear all;
load('dbstims.mat');

% datapath
dataroot = '/media/carsen/DATA2/grive/10krecordings/imgResp';
matroot = '/media/carsen/DATA2/grive/10krecordings/stimResults/';        

stimset={'natimg2800','white2800','natimg2800_8D','natimg2800_4D','natimg2800_small','ori'};

load(fullfile(matroot,'eigsAllStats.mat'));
d=load(fullfile(matroot,'eigsControls_natimg2800.mat'));
load(fullfile(matroot,'natimg32_reps'));  % from powerlaw_natimg32.m
load(fullfile(dataroot,sprintf('%sProc.mat',stimset{1})));    

%isess = [31,48,57,60,66,75,83, 94, 104, 120]; %% 1 is central, 2 is center-left, 3 is center-low,5,6 are central, 4+7 are left screen,low and center

gb=load(fullfile(matroot,'gaborFits.mat'));
specG = [];

specG = NaN*zeros(2800, numel(specS{1}));
for j = 1:length(specS{1})
    specG(1:numel(gb.specS{j}), j) = gb.specS{j};
end

%%
load(fullfile(dataroot, sprintf('%sProc.mat',stimset{1})));

%%
my_index = 6;
respBz  = respAll{my_index};

% neuron variance
repvar = mean(respBz(:,:,1).*respBz(:,:,2), 1);
vexpALL = repvar;
% stimulus variance
repvar = mean(zscore(respBz(:,:,1),1,2).*zscore(respBz(:,:,2),1,2), 2);
vstimALL = repvar;

R1 = gpuArray(single(respBz(:,:,1)));

[~, ~, C] = svdecon(R1);
C = gather(C);

clear cproj
srange = 1:size(respBz,1);
cproj(:,:,1) = respBz(srange,:,1) * C;
cproj(:,:,2) = respBz(srange,:,2) * C;

%
rng('default');
iexample = my_index;

[Nstim, NN, nreps] = size(respBz);

[~, ix] = sort(vexpALL, 'descend');
[~, istim] = sort(vstimALL, 'descend');                          

rng(102);
% istim = istim(randperm(Nstim));
ix    = ix(randperm(NN));


%%
close all
default_figure([15 1 4.5 6.]);

%%
clf;


col = colormap('lines');
% axes('position', [.1 .9 .25 .05])
% imagesc(respB(istim(1:nstim),ix(1:nn),1)', [-2 2])
% colormap(redblue)
% set(gca,'xtick', [], 'ytick', [])
% text(0, 1.5, 'Data matrix','fontsize',12)
% text(0.02, 0.85, 'train', 'horizontalalignment', 'left', 'verticalalignment', 'middle','fontsize',11)
% %text(-.15, 1.5, 'a', 'Fontweight', 'bold', 'Fontangle', 'normal', 'Units', 'normalized', 'verticalAlignment', 'top', 'Fontsize', 12);
% ylabel('neurons','fontsize',12)
% 
% axes('position', [.1 .845 .25 .05])
% imagesc(respB(istim(1:nstim),ix(1:nn),2)', [-2 2])
% set(gca,'xtick', [], 'ytick', [])
% text(.02, 0.85, 'test', 'horizontalalignment', 'left', 'verticalalignment', 'middle','fontsize',11)
% xlabel('stimuli','fontsize',12)

nstim = 25;
nn    = 20;
dy1 = 0.03;
clear hs;
hs{1}=my_subplot(4,3,1,[.6 .6]);
axis off;

hp=my_subplot(4,1,1,[.9 .9]);
hp.Position(3) = hp.Position(3)*.7;
hp.Position(1) = hp.Position(1)-.03;
img=imread('schematic.png');
imagesc(img)
axis image;
axis off;

hp=my_subplot(4,3,3,[.75 .5]);
axis off;
axes('position', [hp.Position(1) hp.Position(2)+hp.Position(3)*.25 hp.Position(3) hp.Position(4)*.6]);
imagesc(cproj(istim(1:nstim),1:nn,1)', [-1 1]*30)
set(gca,'xtick', [], 'ytick', [])
%text(0, 1.2, 'PCs (1-20)','fontsize',12)
text(-.23, 0.5, {'PC','train'}, 'horizontalalignment', 'left', 'verticalalignment', 'middle','fontsize',8)
%text(-.15, 1.5, 'd', 'Fontweight', 'bold', 'Fontangle', 'normal', 'Units', 'normalized', 'verticalAlignment', 'top', 'Fontsize', 12);

axes('position', [hp.Position(1) hp.Position(2)-.03 hp.Position(3) hp.Position(4)*.6]);
imagesc(cproj(istim(1:nstim),1:nn,2)', [-1 1]*30)
set(gca,'xtick', [], 'ytick', [])
text(-.23, 0.5, {'PC','test'}, 'horizontalalignment', 'left', 'verticalalignment', 'middle','fontsize',8)
xlabel('stimuli','fontsize',8)
colormap(redblue);

xh = .6;
yh = .6;

yH = .37;

S = NaN*zeros(2800, numel(specS{1}));
for j = 1:length(specS{1})
    S(1:numel(specS{1}{j}), j) = specS{1}{j};
end


% ///// cumulative plot with 32 img responses
i=1;
i=i+1;
hs{i}=my_subplot(4,3,4,[xh yh]);
hs{i}.Position(2)= hs{i}.Position(2) + dy1;
Scum = cumsum(S);
semilogx(nanmean(Scum,2))
hold on
shadedErrorBar([1:size(S,1)]', nanmean(Scum,2), ...
    nanstd(Scum,1,2)/sqrt(size(S,2)-1), {'Linewidth', .5, 'Color', 'b'});

S32 = ones(1824, numel(spec32));
for j = 1:length(spec32)
    S32(1:numel(spec32{j}), j) = (spec32{j});
end
S32(S32<0) = 0;
S32 = cumsum(S32);
%clf;
semilogx(nanmean(S32,2),'color',[.5 .5 0]);
shadedErrorBar([1:size(S32,1)]', nanmean(S32,2), ...
    nanstd(S32,1,2)/sqrt(size(S32,2)-1), {'Linewidth', .5, 'Color', [.5 .5 0]});
%
text(.65, .55, {'2800', 'images'}, 'Horizontalalign', 'left', 'Fontsize', 8, 'Color', 'b')
text(.03, 1.2, {'32 images'}, 'Horizontalalign', 'left', 'Fontsize', 8, 'Color', [.5 .5 0])
           
plot([32 32], 10.^[-5 0],'--','color',[0 0 0]);
ylabel({'variance','(cumulative)'})
set(gca, 'ytick', [0:.2:1],'xtick',10.^[0:3])
ylim([0 1]);
xlim([0 size(S32,1)])
box off;
xlabel('PC dimension');
axis square

% //////////////// averaged spectrum
i=i+1;
hs{i}=my_subplot(4,3,5,[xh yh]);
hs{i}.Position(2)= hs{i}.Position(2) + dy1;
loglog(nanmean(S,2))
hold on
shadedErrorBar([1:size(S,1)]', nanmean(S,2), ...
    nanstd(S,1,2)/sqrt(size(S,2)-1), {'Linewidth', .5, 'Color', 'b'});

ylim(10.^[-5 -.5])
xlim([0 2800]);
ylabel('variance')
set(gca,'ytick', 10.^[-5:0])
set(gca,'xtick', 10.^[0:4])
[p,ypred]=get_powerlaw(nanmean(S,2),10:500);
plot(ypred,'k');
text(.5, .77, sprintf('\\alpha=%2.2f', p),'fontweight','bold','fontsize',8,...
    'fontangle','normal','color','b')
box off;
xlabel('PC dimension');
grid on;
grid minor;
grid minor;
axis square;

% /////////// all spectrums
i=i+1;
hs{i}=my_subplot(4,3,6,[xh yh]);
hs{i}.Position(2)= hs{i}.Position(2) + dy1;
loglog(S,'linewidth',.5)
grid on;
grid minor;
grid minor;

ylim(10.^[-5 -.5])
xlim([0 2800]);
ylabel('variance')
text(0.1, 1.1, {'(all recordings)'},'fontsize',8,'fontangle','normal')
set(gca,'ytick', 10.^[-5:0])
set(gca,'xtick', 10.^[0:4])
box off;
xlabel('PC dimension');
axis square;

% /////////// histogram of alpha

i=i+1;
hs{i}=my_subplot(4,3,7,[xh yh]);
hs{i}.Position(2)= hs{i}.Position(2) + dy1/2;
pall = zeros(1, length(specS{1}));
for j = 1:length(specS{1})
    [pall(j), ypred, b] = get_powerlaw(specS{1}{j}, 10:500);
end
histogram(pall,[.75:.05:1.1],'facecolor',[.5 .5 .5]);%,[.79:.05:1.25])
ylabel('# of recordings')
xlim([.85 1.15]);
%set(gca,'xtick',[.5:.25:1.25]);
box off;
xlabel('power law exponent \alpha');
axis square;

%grid on;
%grid minor;
%grid minor;


% ////////////// cumulative spectrum

i=i+1;
hs{i}=my_subplot(4,3,8,[xh yh]);
hs{i}.Position(2)= hs{i}.Position(2) + dy1/2;
Scum = cumsum(S);
semilogx(nanmean(Scum,2))
hold on
shadedErrorBar([1:size(S,1)]', nanmean(Scum,2), ...
    nanstd(Scum,1,2)/sqrt(size(S,2)-1), {'Linewidth', .5, 'Color', 'b'});
sG = cumsum(specG);
semilogx(nanmean(sG,2),'m');
shadedErrorBar([1:size(specG,1)]', nanmean(sG,2), ...
    nanstd(sG,1,2)/sqrt(size(specG,2)-1), {'Linewidth', .5, 'Color', 'm'});
text(-.0,1.2,{'classical RF model'},'fontsize',8,'color','m');
grid on;
grid minor;
grid minor;

box off;
ylim([0 1]);
xlim([0 2800])
%set(gca,'ytick', 10.^[-5:0])
set(gca,'xtick', 10.^[0:4],'ytick',[0:.2:1])
box off;
xlabel('PC dimension');
ylabel({'variance','(cumulative)'});
text(.65, .55, {'neural', 'data'}, 'Horizontalalign', 'left', 'Fontsize', 8, 'Color', 'b')
axis square;

blu = [0 0 1];
red = [1 0 0];
green = [0 .5 0];

nfrac = 2.^[0:-1:-7];
sfrac = 2.^[0:-1:-7];

nl =  7;
nfrac = nfrac(1:nl);
sfrac = sfrac(1:nl);

ip = 0;
for ij = 1:2
    if ij == 1
        col = [linspace(blu(1), red(1), nl); ...
            linspace(blu(2), red(2), nl); linspace(blu(3), red(3), nl)]';
    else
        col = [linspace(blu(1), green(1), nl); ...
            linspace(blu(2), green(2), nl); linspace(blu(3), green(3), nl)]';
    end
    cols{ij}=col;
    
    i=i+1;
    hs{i}=my_subplot(4,3,ij+8,[xh yh]);
    if ij==1
        hs{i}.Position(2)= hs{i}.Position(2) + dy1/2;
    end
    p=NaN*zeros(nl, size(specS{1,ij},2));
    r=NaN*zeros(nl, size(specS{1,ij},2));
    sA = NaN*zeros(2800, 10, size(specS,2));
    
    irange = 1:size(d.specS{1,ij},2);
    
    for j = 1:nl
        clear sA;
        fmax = 1e4;
        for k=irange
            ss=d.specS{j,ij}(:,k);
            %ss = ss(:)/nansum(ss);
            fnan = find(isnan(ss),1)-1;
            if isempty(fnan); fnan = numel(ss)-1; end
            if ij == 1
                if fnan > nfrac(j)*d.NumNeu(k)
                    fnan = nfrac(j)*d.NumNeu(k);
                end
            end
            trange0 = 11:max(12,min(500, (round(fnan*.5))));
            [p(j,k), ypred, b(j,k), r(j,k)] = get_powerlaw(ss, trange0);
            tplot = round(min(min(500,fnan*.5), numel(ss)));
            sA(1:tplot,k) = ss(1:tplot)/nansum(ss(1:tplot));
            fmax = min(tplot, fmax);
            
        end
        loglog(nanmean(sA(1:fmax,:),2), 'Color', col(j,:));
        hold all;
        
        text(1.04, 1.32-(j-1)*.1, sprintf('%2.3f', nfrac(j)), 'HorizontalAlign', 'right', ...
            'Color', col(j,:),'fontsize',6,'fontangle','normal');
    end
    
    if ij == 1
        text(.0, 1.32, {'fraction of', 'all neurons:'}, 'HorizontalAlign', 'left','fontsize',8)
    else
        text(.0, 1.32, {'fraction of', 'all stimuli:'}, 'HorizontalAlign', 'left','fontsize',8)
    end
    box off
    ylim(10.^[-4 -.5])
    xlim([1 500])
    set(gca, 'xtick', 10.^[0 1 2 3], 'ytick', 10.^[-5:1:-1])
    ylabel('variance')
    xlabel('dimension')
    grid on;
    grid minor;
    grid minor;
    axis square
    %
    ps{ij} = p;
    rs{ij} = r;
end

for kt = 1:2
    if kt==1
        wp = rs;
    else
        wp = ps;
    end
    i=i+1;
    hs{i}=my_subplot(4,3,2+kt+8,[xh yh]);
    
    for ij = 1:2
        p = wp{ij};
        semilogx(nfrac, nanmean(p,2),'k');
        hold all;
        for j = 1:numel(nfrac)
            errorbar(nfrac(j), nanmean(p(j,:)), nanstd(p(j,:))/sqrt(size(p,2)),'.','color',cols{ij}(j,:),'markersize',10);
        end
            
    end
    axis tight;
    box off;
    if kt == 1
        ylabel({'correlation','coefficient'});
        ylim([.4 1.05]);
    else
        ylabel({'power law','exponent'});
        ylim([.25 1.5]);
    end
    xlabel({'fraction of','neurons/stimuli'});
    axis square;
end
    
%%
for j = 1:length(hs)
    axes(hs{j});
    if j ==1
        jy = 1.3 ;
        jx = -.45;
    else
        jy = 1.3;
        jx = -.45;
    end
    text(jx,jy,char(96+j),'units','normalized','fontsize',11,'fontweight','bold','fontangle','normal');
end



%%

print('../figs/fig2new.pdf','-dpdf');