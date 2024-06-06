% External validation
% Input: training = feature matrix of training samples (group IDs in the last column)
%        testing = feature matrix of testing samples (group IDs in the last column)
%        method = 'SVM','LDA','KNN' (default K=1)
% Optional Input: PCA = 0 (no PCA - default), 1 (PCA scores - number of scores determined by training holdout)
%                 Fscore = 0 (no feature selection - default), 1 (SVM+FScore feature selection)
%                 dist = type of distance for KNN classifier ('C' (default),'E','L','K','G','L1')
function [SR,CM,prob] = classifyDescriptorsExternal(training,testing,method,varargin)

% Parsing optional input:
options = struct('PCA',0,'FScore',0,'dist','C');
optionNames = fieldnames(options);
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    error('Optional arguments are propertyName/propertyValue pairs')
end
for pair = reshape(varargin,2,[]) %# pair is {propName;propValue}
    inpName = pair{1}; %# make case insensitive
    if any(strcmp(inpName,optionNames))
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end 

if options.PCA
    maxPCA = min(50,size(training,2)-1);%size(dat,2)-1; % maximum number of PCA components
    [trainingSet,testingSet] = applyPCA(testing(:,1:end-1),training(:,1:end-1),training(:,end),method,maxPCA,dist);
else
    trainingSet = training(:,1:end-1);
    testingSet = testing(:,1:end-1);
end
if FScore
    if i == 1
        % The code below is specific for multifractal features
        indF1 = applyFScore(training(:,1:26),training(:,end));
        indF2 = applyFScore(training(:,27:52),training(:,end));
        indF3 = applyFScore(training(:,53:78),training(:,end));
        indF = [indF1 indF2+26 indF3+52];
        % The code below is for general purposes
        %indF = applyFScore(training(:,1:end-1),training(:,end));
    end
    trainingSet = training(:,indF);
    testingSet = testing(:,indF);        
else
    trainingSet = training(:,1:end-1);
    testingSet = testing(:,1:end-1);
end    

switch method
    case 'SVM'
        class = multisvm_classify(testingSet,trainingSet,training(:,end));
        SR = sum(class==testing(:,end))/length(class)*100;
        CM = confusionmat(testing(:,end),class);
    case 'LDA'
        class = classify(testingSet,trainingSet,training(:,end));
        SR = sum(class==testing(:,end))/length(class)*100;
        CM = confusionmat(testing(:,end),class);
    case 'KNN'
        class = KNN(testingSet,trainingSet,training(:,end),dist,1);         
        SR = sum(class==testing(:,end))/length(class)*100;
        CM = confusionmat(testing(:,end),class);        
end

prob = []; % not implemented