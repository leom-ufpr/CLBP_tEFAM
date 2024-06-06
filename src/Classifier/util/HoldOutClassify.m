% K-fold classification
% Input: dat = feature matrix (group IDs in the last column)
%        method = 'SVM','LDA','KNN'
%        strat = 0 (random), 1 (stratified)
%        PCA = 0 (no PCA), 1 (PCA)
%        FScore = 0 (no Fisher score + SVM feature selection), FScore = 1
%        (FScore)
function [SR,error,CM,prob] = HoldOutClassify(dat,method,strat,PCA,FScore,dist)

K = 5; % default 5-fold
nl = size(dat,1);
if strat
    indices = stratifiedCrossVal(dat(:,end),'HoldOut');
    indTrain = (indices == 1);
    indTest = (indicess == 2);
else
    [indTrain,indTest] = crossvalind('HoldOut',dat(:,end),0.5);
end

if PCA
    maxPCA = min(50,size(dat,2)-1);%size(dat,2)-1; % maximum number of PCA components
    [trainingSet,testingSet] = applyPCA(dat(indTest,1:end-1),dat(indTrain,1:end-1),dat(indTrain,end),method,maxPCA,dist);
else
    trainingSet = dat(indTrain,1:end-1);
    testingSet = dat(indTest,1:end-1);
end

if FScore
    % The code below is specific for multifractal features
    indF1 = applyFScore(dat(indTrain,1:26),dat(indTrain,end));
    indF2 = applyFScore(dat(indTrain,27:52),dat(indTrain,end));
    indF3 = applyFScore(dat(indTrain,53:78),dat(indTrain,end));
    indF = [indF1 indF2+26 indF3+52];
    trainingSet = dat(indTrain,indF);
    testingSet = dat(indTest,indF);    
    % The code below for general purposes
    % indF = applyFScore(dat(indTrain,1:end-1),dat(indTrain,end));
else
    trainingSet = dat(indTrain,1:end-1);
    testingSet = dat(indTest,1:end-1);
end

switch method
    case 'SVM'
        class = multisvm_classify(testingSet,trainingSet,dat(indTrain,end));
        SR = sum(class==dat(indTest,end))/length(class)*100;
    case 'LDA'  
        class = classify(testingSet,trainingSet,dat(indTrain,end));
        SR = sum(class==dat(indTest,end))/length(class)*100;
    case 'KNN'
        class = KNN(testingSet,trainingSet,dat(indTrain,end),'C',1);         
        SR = sum(class==dat(indTest,end))/length(class)*100;
end

CM = confusionmat(dat(indTest,end),class);
error = 0;
prob = []; % to be implemented