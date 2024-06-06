function class = multisvm_classify(sample,training,groups)

labels = unique(groups);
numLabels = length(labels);

%# split training/testing
numTrain = size(training,1); numTest = size(sample,1);
trainData = training;  testData = sample;
trainLabel = groups;

trainData = zscore(trainData);              %# scale features
testData = zscore(testData);

%# train one-against-all models
model = cell(numLabels,1);
for k=1:numLabels
    model{k} = svmtrain(double(trainLabel==labels(k)), trainData, '-c 1 -g 0.2 -b 1 -q');
end

%# get probability estimates of test instances using each model
prob = zeros(numTest,numLabels);
for k=1:numLabels
    [~,~,p] = svmpredict(double(rand(numTest,1)), testData, model{k}, '-b 1 -q');
    prob(:,k) = p(:,model{k}.Label==1);    %# probability of class==k
end

%# predict the class with the highest probability
[~,pred] = max(prob,[],2);
class = pred;