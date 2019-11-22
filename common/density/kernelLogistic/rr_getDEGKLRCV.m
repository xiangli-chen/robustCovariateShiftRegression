function [srcData,tarData,bestR] = rr_getDEGKLRCV(srcData,tarData,crossV,regulator)
% design training data for logistic regression
% y=-1 is source and y=1 is target
options.Display = 'full';
srcInput = srcData.input;
nSrc = size(srcInput,2);
% d = size(srcInput,1);
XSrc = [ones(nSrc,1) srcInput'];
ySrc = -ones(nSrc,1);
tarInput = tarData.input;
nTar = size(tarInput,2);
XTar = [ones(nTar,1) tarInput'];
yTar = ones(nTar,1);

portionSrc = floor(nSrc/crossV);
portionTar = floor(nTar/crossV);

bestLogLH = -realmax;
bestR = 0;
for r = regulator
    logLH = 0;
    for c = 1:crossV
        startSrc = (c-1)*portionSrc+1;
        startTar = (c-1)*portionTar+1;
        if(c<crossV)
            endSrc = c*portionSrc;
            endTar = c*portionTar;
        else
            endSrc = nSrc;
            endTar = nTar;
        end
        evalSrc = XSrc(startSrc:endSrc,:);
        evalTar = XTar(startTar:endTar,:);
        trainSrc = XSrc;
        trainSrc(startSrc:endSrc,:) = [];
        trainTar = XTar;
        trainTar(startTar:endTar,:) = [];
        XTrain = [trainSrc;trainTar];
        yTrain = [-ones(size(trainSrc,1),1);ones(size(trainTar,1),1)];
        nTrainData = size(XTrain,1);
        lambda = r/sqrt(nTrainData);
        rbfScale = 1;
        Krbf = kernelRBF(XTrain,XTrain,rbfScale);
        funObj = @(u)LogisticLoss(u,Krbf,yTrain);
        fprintf('Training kernel(rbf) logistic regression model...\n');
        uRBF = minFunc(@penalizedKernelL2,zeros(nTrainData,1),options,Krbf,funObj,lambda);     
        KrbfEvalSrc = kernelRBF(evalSrc,XTrain,rbfScale);
        KrbfEvalTar = kernelRBF(evalTar,XTrain,rbfScale);
        logPEvalSrc = log(1./(1+exp(KrbfEvalSrc*uRBF)));
        logPEvalTar = log(exp(KrbfEvalTar*uRBF)./(1+exp(KrbfEvalTar*uRBF)));
%         % nVars = d;
%         % linear logistic regression
%         funObj = @(w)LogisticLoss(w,XTrain,yTrain);
%         lambda = r*ones(nVars+1,1);
%         lambda(1) = 0; % Don't penalize bias
%         fprintf('Training L2-regularized logistic regression model...\n');
%         wL2 = minFunc(@penalizedL2,zeros(nVars+1,1),options,funObj,lambda);
%         % compute conditional logloss
%         logPEvalSrc = log(1./(1+exp(evalSrc*wL2)));
%         logPEvalTar = log(exp(evalTar*wL2)./(1+exp(evalTar*wL2)));
        logLH = logLH + sum(logPEvalSrc)+sum(logPEvalTar);
    end
    if(logLH > bestLogLH)
        bestLogLH = logLH;
        bestR = r;
    end
end

X = [XSrc;XTar];
y = [ySrc;yTar];

% Squared exponential radial basis function kernel expansion
nInstances = nSrc+nTar;
lambda = bestR/sqrt(nInstances);
rbfScale = 1;
Krbf = kernelRBF(X,X,rbfScale);
funObj = @(u)LogisticLoss(u,Krbf,y);
fprintf('Training kernel(rbf) logistic regression model...\n');
uRBF = minFunc(@penalizedKernelL2,zeros(nInstances,1),options,Krbf,funObj,lambda);
kernelModel = Krbf*uRBF;

% pSrc = 1./(1+exp(kernelModel(1:nSrc)));
% pTar = 1-1./(1+exp(kernelModel(nSrc+1:end)));

importance = ((nSrc./nTar).*exp(kernelModel));
importance = importance';
srcData.importance = importance(1:nSrc);
srcData.weight = 1./srcData.importance;
tarData.weight = 1./importance(nSrc+1:end);
