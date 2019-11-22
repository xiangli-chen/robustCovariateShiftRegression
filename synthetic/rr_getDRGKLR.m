function [srcData,tarData] = rr_getDRGKLR(srcData,tarData)
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

X = [XSrc;XTar];
y = [ySrc;yTar];

% Squared exponential radial basis function kernel expansion
nInstances = nSrc+nTar;
lambda = 1e-2;
rbfScale = 1;
Krbf = kernelRBF(X,X,rbfScale);
funObj = @(u)LogisticLoss(u,Krbf,y);
fprintf('Training kernel(rbf) logistic regression model...\n');
uRBF = minFunc(@penalizedKernelL2,zeros(nInstances,1),options,Krbf,funObj,lambda);
kernelModel = Krbf*uRBF;

importance = ((nSrc./nTar).*exp(kernelModel));
importance = importance';
srcData.importance = importance(1:nSrc);
srcData.weight = 1./srcData.importance;
tarData.weight = 1./importance(nSrc+1:end);
