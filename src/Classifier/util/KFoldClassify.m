% K-fold classification
% Input: dat = feature matrix (group IDs in the last column)
%        method = 'SVM','LDA','ChiKNN'
%        strat = 0 (random), 1 (stratified)
function [SR,error,CM,prob,classes] = KFoldClassify(dat,method,strat,PCA,FScore,dist)

K = 5; % default 5-fold

nl = size(dat,1);
nbrOfGroups = length(unique(dat(:,end)));
if strat
    indices = stratifiedCrossVal(dat(:,end),'KFold');
else
    indices = crossvalind('Kfold',dat(:,end),K); % K-fold takes into account the group distribution
end

CM = zeros(nbrOfGroups,nbrOfGroups);
for i = 1:K
    indTest = find(indices == i); indTrain = setdiff([1:nl],indTest);
    if PCA
        maxPCA = min(50,size(dat,2)-1);%size(dat,2)-1; % maximum number of PCA components
        [trainingSet,testingSet] = applyPCA(dat(indTest,1:end-1),dat(indTrain,1:end-1),dat(indTrain,end),method,maxPCA,dist);
    else
        trainingSet = dat(indTrain,1:end-1);
        testingSet = dat(indTest,1:end-1);
    end
    if FScore
        if i == 1
            % The code below is specific for multifractal features
            indF1 = applyFScore(dat(indTrain,1:26),dat(indTrain,end));
            indF2 = applyFScore(dat(indTrain,27:52),dat(indTrain,end));
            indF3 = applyFScore(dat(indTrain,53:78),dat(indTrain,end));
            indF = [indF1 indF2+26 indF3+52];
            % The code below is for general purposes
            %indF = applyFScore(dat(indTrain,1:end-1),dat(indTrain,end));
        end
        trainingSet = dat(indTrain,indF);
        testingSet = dat(indTest,indF);        
    end   
    
    switch method
        case 'SVM'
            class = multisvm_classify(testingSet,trainingSet,dat(indTrain,end));
            SR_aux(i) = sum(class==dat(indTest,end))/length(class)*100;
            CM = CM + confusionmat(dat(indTest,end),class);
        case 'LDA'  
            class = classify(testingSet,trainingSet,dat(indTrain,end));
            SR_aux(i) = sum(class==dat(indTest,end))/length(class)*100;
            CM = CM + confusionmat(dat(indTest,end),class);
        case 'KNN' % default K = 1
            class = KNN(testingSet,trainingSet,dat(indTrain,end),dist,1);    
            SR_aux(i) = sum(class==dat(indTest,end))/length(class)*100;
            CM = CM + confusionmat(dat(indTest,end),class);
            classes(indTest) = class;
    end
end

SR = mean(SR_aux);
error = std(SR_aux);
prob = []; % to be implemented