clear;
path = '../common/';
path = genpath(path);
addpath(path);
%addpath('../common/KDE');
%pth = '../common/KDE/tools';
%rmpath(pth);
%addpath(pth);
%load('concrete_input');

load('syntheticData');

%D_input = D_input([3 end],:);
%data = D_input;
%D_X = rr_dimReduction(D_input(1:end-1,:),0.9);
%D_input = [D_X;D_input(end,:)];
d = size(D_src,1)-1;

% number of running
logLossMatrix = zeros(6,1);
i=1;
%initialize
srcData.input = D_src(1:end-1,:);
srcData.output = D_src(end,:);
tarData.input = D_tar(1:end-1,:);
tarData.output = D_tar(end,:);

% %--------------- density estimation ---------------
% % kernel density estimation
% crossValidation = 10;
% interval = 0.02;
% [srcData,tarData] = rr_getKernelDensityEst(srcData,tarData,crossValidation,interval);
% % get importance and weight
% srcData.importance = srcData.pTar./srcData.pSrc;
% srcData.weight = srcData.pSrc./srcData.pTar;
% tarData.weight = tarData.pSrc./tarData.pTar;

% % logistic regression
% 
% % get density ratio via L2-regularized linear logistic regression
% crossV = 10;
% regulator = [0 0.1 1 5 10 30 100];
% [srcData,tarData,bestR] = rr_getDRLLR(srcData,tarData,crossV,regulator);

% get density ratio via Gaussian kernel logistic regression
[srcData,tarData] = rr_getDRGKLR(srcData,tarData);


%--------------- methods -----------------
%-----------baseline method
y_min = min(srcData.output);
y_max = max(srcData.output);
[meanBase,varBase] = rr_getDisBase(y_min,y_max);

%     % get mean and variance of base distribution via target data
%     [meanBaseTar,varBaseTar] = rr_getDisBase(D_tar);
%     % get sample mean and sample variance of base distribution
%     [meanBaseSample,varBaseSample] = stat_getSampleMVar(D_tar(end,:)');
%----------- linear method
% get theta estimated variance for different gamma
[thetaList,gammaList,estVarList] = rr_getWLR(srcData);
%[thetaList,gammaList,estVarList]=rr_getWLR(D_src,D_tar,H_src,H_tar);
baseLogLoss = rr_getBaseLogLoss(tarData,meanBase,varBase);
% baseTarLogLoss = rr_getBaseLogLoss(D_tar,meanBaseTar,varBaseTar);
% baseSampleLogLoss = rr_getBaseLogLoss(D_tar,meanBaseSample,varBaseSample);

lsLogLoss = rr_getIWLogLoss(0,tarData,gammaList,thetaList,estVarList);
%lsAIWMLogLoss = rr_getBIWLogLoss(0.5,D_tar,gammaList,thetaList,estVarList);
lsBAIWMLogLoss = rr_getBestAIWLogLoss(tarData,gammaList,thetaList,estVarList);
lsIWMLogLoss = rr_getIWLogLoss(1,tarData,gammaList,thetaList,estVarList);
lsBLogLoss = rr_getBLogLoss(srcData,tarData,1*eye(d+1),estVarList(:,1));

%----------- robust method
% get the lagrangian multiplier matrix of robust regression
% the last three parameters stopThd, rateInitial, decayTune
M = rr_getLagMul(srcData,meanBase,varBase,1e-2,1e-2,300);
robustLogLoss = rr_getRobustLogLoss(M,tarData,meanBase,varBase);
logLossMatrix(:,i)=[robustLogLoss;baseLogLoss;lsLogLoss;lsBAIWMLogLoss;lsIWMLogLoss;lsBLogLoss];
display(mean(logLossMatrix,2));
save('logLossMatrix','logLossMatrix');
display(mean(logLossMatrix,2));
