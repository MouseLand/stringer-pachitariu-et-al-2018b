function imgs = loadImages(stimtype, nscreen, nscale, nimg)

if nargin < 2
    nscreen = 2;
    nimg = Inf;
elseif nargin < 3
	nscale = 1;
elseif nargin < 4
    nimg = Inf;
end
    

for K = 1:numel(stimtype)
    iskip=0;
    switch stimtype{K}
        case 'natimg'
            root = '/media/carsen/DATA1/naturalimages/selection2800/';
        case '4D'
            root = '/media/carsen/DATA1/naturalimages/selection4833/';
        case '8D'
            root = '/media/carsen/DATA1/naturalimages/selection2833/';
        case 'small'
            root = '/media/carsen/DATA1/naturalimages/selection2733/';
        case 'white'
            root = '/media/carsen/DATA1/naturalimages/selection1800/';
        otherwise
            iskip=1;
            
    end
    
    if ~iskip
        fimg=dir(fullfile(root,'*.mat'));
        nload = min(length(fimg), nimg);
        
		imgs{K} = zeros(nscale*67,nscale*90*nscreen, nload, 'single');
        
		%
        for j = 1:nload
            load(fullfile(root, sprintf('img%d.mat',j)));
            
			img = imresize(img, nscale*270/size(img,2));

			% if two screens, use left and center
			if nscreen == 2
				img = img(1:67*nscale, 1:180*nscale);
			elseif nscreen == 1
				img = img(1:67*nscale, [1:90*nscale] + 90*nscale);
            end
            imgs{K}(:,:,j) = img;
            
        end
        
    elseif strcmp(stimtype{K},'sparse')
        %%
        nimg = 2800;
        imgs{K} = zeros(nscale*67,nscale*90*nscreen, nimg, 'single');
        
		gsize = [13 18];
		gup   = 5;
        img = zeros(gsize(1),gsize(2)*nscreen,nimg,'single');
        img(rand(size(img))<.2) = 1;
        img = img .* (2*randi(2,gsize(1),gsize(2)*nscreen,nimg)-3);
        
        img = reshape(img, 1, gsize(1), 1, gsize(2)*nscreen, nimg);
        img = repmat(img, gup*nscale, 1, gup*nscale, 1, 1);
        img = reshape(img, gup*gsize(1)*nscale, gup*gsize(2)*nscreen*nscale, nimg);
        
        imgs{K}([1:size(img,1)], [1:size(img,2)], :) = img;
        
    elseif strcmp(stimtype{K},'ori')
        %%
        nimg = 32;
        imgs{K} = zeros(nscale*67,nscale*90*nscreen, nimg, 'single');
        [x,y] = ndgrid([1:67*nscale],[1:90*nscreen*nscale]);
        for j = 1:nimg
            theta = 2*pi*j/64;
            sx = cos(2*pi*((x-67/2)*sin(theta) + (y-179/2)*cos(theta))/(20*nscale)) ;
            imgs{K}(:,:,j) = sx;
        end
        
    end
    
    
end

