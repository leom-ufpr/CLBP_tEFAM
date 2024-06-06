function[acerto,C,prob] = multisvm_fold_externo(treino,teste)

[~,~,labels] = unique(treino(:,end));   %# labels: 1/2/3/...
numLabels = max(labels);

%# split training/testing
numTrain = size(treino,1); numTest = size(teste,1);
trainData = treino(:,1:end-1);  testData = teste(:,1:end-1);
trainLabel = treino(:,end); testLabel = teste(:,end);

trainData = zscore(trainData);              %# scale features
testData = zscore(testData);

% Análise canônica
% addpath E:\Doutorado\Implementação\Matlab_texturas\Misc\Classificação;
% Xtr = canonica_transf([trainData trainLabel]); Xts = canonica_transf([testData testLabel]);
% trainData = Xtr(:,1:20);testData = Xts(:,1:20);

%# train one-against-all models
model = cell(numLabels,1);
for k=1:numLabels
    model{k} = svmtrain(double(trainLabel==k), trainData, '-c 1 -g 0.2 -b 1 -q');
end

%# get probability estimates of test instances using each model
prob = zeros(numTest,numLabels);
for k=1:numLabels
    [~,~,p] = svmpredict(double(testLabel==k), testData, model{k}, '-b 1 -q');
    prob(:,k) = p(:,model{k}.Label==1);    %# probability of class==k
end

%# predict the class with the highest probability
[maxprob,pred] = max(prob,[],2);
acc = sum(pred == testLabel) ./ numel(testLabel);    %# accuracy
C = confusionmat(testLabel, pred);                   %# confusion matrix
acerto = acc*100;