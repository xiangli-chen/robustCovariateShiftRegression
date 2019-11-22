function [srcData,tarData,bestR] = rr_getDRLLR(srcData,tarData,crossV,regulator)
% design training data for logistic regression
% y=-1 is source and y=1 is target
options.Display = 'full';
srcInput = srcData.input;
nSrc = size(srcInput,2);
d = size(srcInput,1);
XSrc = [ones(nSrc,1) srcInput'];
ySrc = -ones(nSrc,1);
tarInput = tarData.input;
nTar = size(tarInput,2);
XTar = [ones(nTar,1) tarInput'];
yTar = ones(nTar,1);

portionSrc = round(nSrc/crossV);
portionTar = round(nTar/crossV);

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
        nVars = d;
        % linear logistic regression
        funObj = @(w)LogisticLoss(w,XTrain,yTrain);
        lambda = r*ones(nVars+1,1);
        lambda(1) = 0; % Don't penalize bias
        fprintf('Training L2-regularized logistic regression model...\n');
        wL2 = minFunc(@penalizedL2,zeros(nVars+1,1),options,funObj,lambda);
        % compute conditional logloss
        logPEvalSrc = log(1./(1+exp(evalSrc*wL2)));
        logPEvalTar = log(exp(evalTar*wL2)./(1+exp(evalTar*wL2)));
        logLH = logLH + sum(logPEvalSrc)+sum(logPEvalTar);
    end
    if(logLH > bestLogLH)
        bestLogLH = logLH;
        bestR = r;
    end
end

X = [XSrc;XTar];
y = [ySrc;yTar];
nVars = d;
% linear logistic regression
funObj = @(w)LogisticLoss(w,X,y);
lambda = bestR*ones(nVars+1,1);
lambda(1) = 0; % Don't penalize bias
fprintf('Training L2-regularized logistic regression model...\n');
wL2 = minFunc(@penalizedL2,zeros(nVars+1,1),options,funObj,lambda);
linearModel = X*wL2;
% trainErr_L2 = sum(y ~= sign(X*wL2))/length(y);

importance = ((nSrc./nTar).*exp(linearModel));
importance = importance';
srcData.importance = importance(1:nSrc);
srcData.weight = 1./srcData.importance;
tarData.weight = 1./importance(nSrc+1:end);
