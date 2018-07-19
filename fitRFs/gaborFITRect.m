%%%% fit gabors from grid of statistics given by A on XY grid of X %%%%%
% fit is an additive model of simple + complex cell
% X: grid of y and x points
% A: npixels x ngabors <- different gabors that are being tested
% yp,xp: possible receptive field centers for each cell
% imgtrain, imgtest: are training and testing images npixels x nimages
% rtrain, rtest: neural responses to images (mean-subtracted)
% (nimages x NNeurons)

% returns training and test variance explained
% ybest, xbest: best RF centers
% gbest: best gabor parameter indices
% cbest: weights of model
% gpred: responses of gabors to test images (images x neurons)

function [vartrain,vartest,ybest,xbest,gbest,cbest,rGtrain,rGtest] = gaborFITRect(X,A, yp, xp, imgtrain,imgtest, rtrain,rtest)

A2 = A;
A2(5,:) = A2(5,:) + pi/2;

vtest  = mean(rtest.^2,1);
vtrain = mean(rtrain.^2,1);

[~,ntrain] = size(imgtrain);
[~,ntest]=size(imgtest);

NN = size(rtrain,2);

rGtrain    = NaN*zeros(NN,ntrain, 'single');
rGtest     = NaN*zeros(NN,ntest, 'single');
vartrain   = NaN*zeros(NN,1,'single');
vartest    = NaN*zeros(NN,1,'single');
gbest      = NaN*zeros(NN,1,'single');
ybest      = NaN*zeros(NN,1,'single');
xbest      = NaN*zeros(NN,1,'single');
cbest      = NaN*zeros(NN,4,'single');

vmax = -100*ones(NN,1);
        
tic;
NG = size(A,2);
%% loop over grid of X,Y positions
for iy = 1:numel(yp)
    for ix = 1:numel(xp)
        
		%% compute gabors at position yp(iy), xp(ix)
		% simple cells
		A(6,:) = yp(iy);
		A(7,:) = xp(ix);
		fg1 = gaborReduced(A,X);
        
		% complex cells
		A2(6,:) = yp(iy);
		A2(7,:) = xp(ix);
		fg2 = gaborReduced(A2,X);
           
        bmax = zeros(NN,2);
        cmax = zeros(NN,2);
        imax = ones(NN,1);
        
		%% compute responses of simple and complex cells
		respG1 = fg1' * imgtrain;
		respG2 = fg2' * imgtrain;
		respG2 = (respG1.^2 + respG2.^2).^.5;                
		% responses are rectified
		respG1 = max(0, respG1);
		respG2 = max(0, respG2);
				
		%% compute coefficients for best fit: r = c1*respG1 + c2*respG2
        % inverted covariance matrices
        clear g11 g22 g12 idet y1 y2;
        g11 = sum((respG1 - mean(respG1,2)).^2, 2);
        g22 = sum((respG2 - mean(respG2,2)).^2, 2);
        g12 = sum((respG1 - mean(respG1,2)) .* (respG2 - mean(respG2,2)), 2);
        idet = 1./ (g11.*g22 - g12.^2);
        
        y1  = (respG1 - mean(respG1,2)) * rtrain;
        y2  = (respG2 - mean(respG2,2)) * rtrain;
        
        % coefficient for simple cell
        c1 = (g22 .* y1 - g12 .* y2) .* idet;
        % coefficient for complex cell
        c2 = (-g12 .* y1 + g11 .* y2) .* idet;
		% only positive coefficients allowed
		c1 = max(0,c1);
		c2 = max(0,c2);
		
		%% variance explained of each gabor
		vexp = c1.*y1 + c2.*y2; 
        clear y1 y2;
        vexp = gather_try(vexp);
        
		% gabors with best variance explained for each neuron
		[mv,im] = max(vexp, [], 1);
		im = im(:);
		m1 = sub2ind(size(vexp), im, [1:NN]');
        		
		% predicted responses from best gabors
		tpred  = c1(m1) .* (respG1(im,:) - mean(respG1(im,:),2)) + ...
			c2(m1) .* (respG2(im,:) - mean(respG2(im,:),2));
        tpred  = gather(tpred);
        vv1 = 1-mean((tpred' - rtrain).^2,1)./vtrain;

		% are predicted responses better than previous responses
		vbetter   = vv1(:) > vmax;
		m1 = sub2ind(size(vexp), im(vbetter), find(vbetter));
		b  = [mean(respG1(im(vbetter),:),2) mean(respG2(im(vbetter),:),2)];
    		
		cmax(vbetter,:)  = gather_try([c1(m1) c2(m1)]);
		bmax(vbetter,:)  = gather_try(b);
		imax(vbetter)    = gather_try(im(vbetter));
		vmax(vbetter)    = gather_try(vv1(vbetter));
		respTrain        = tpred(vbetter, :);
		vv1              = vv1(vbetter);
        
		%% test prediction
		respG1 = fg1' * imgtest;
		respG2 = fg2' * imgtest;
		respG2 = (respG1.^2 + respG2.^2).^.5;                
		respG1 = max(0, respG1);
		respG2 = max(0, respG2);
		tpred  = c1(m1).*(respG1(im(vbetter),:) - b(:,1)) + ...
			c2(m1).*(respG2(im(vbetter),:) - b(:,2));
		tpred = gather(tpred);
        respTest = tpred;
		
		% test variance
		vv2 = 1-mean((tpred' - rtest(:,vbetter)).^2,1)./vtest(vbetter);

        %% update best parameters and predictions
        cbest(vbetter,:) = [gather_try(cmax(vbetter,:)) gather_try(bmax(vbetter,:))];
        vartest(vbetter) = vv2;
		vartrain(vbetter) = gather(vmax(vbetter));
        ybest(vbetter) = yp(iy);
        xbest(vbetter) = xp(ix);
        gbest(vbetter) = gather_try(imax(vbetter));
        rGtrain(vbetter,:) = respTrain;
        rGtest(vbetter,:)  = respTest;
        
    end
    %fprintf('RF Y %d done, %.2f sec, %1.3f train, %1.3f test\n',yp(iy),toc, nanmean(vartrain), nanmean(vartest));
end
fprintf('>>> %1.3f train variance, %1.3f test variance\n', nanmean(vartrain), nanmean(vartest));





















