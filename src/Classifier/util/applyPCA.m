  function [trainingPCA,testingPCA] = applyPCA(sample,training,groups,method,maxPCA,dist)
    
    nl = size(training,1);
    [indTrain,indTest] = crossvalind('HoldOut',groups,0.5);    
    
    [~,datPCA] = princomp(training);
    
    switch method
       case 'SVM'
         for i = 1:maxPCA
           class = multisvm_classify(datPCA(indTest,1:i),datPCA(indTrain,1:i),groups(indTrain));
           SR_aux(i) = sum(class==groups(indTest))/length(class)*100;
         end
       case 'LDA'
         for i = 1:maxPCA         
           class = classify(datPCA(indTest,1:i),datPCA(indTrain,1:i),groups(indTrain));
           SR_aux(i) = sum(class==groups(indTest))/length(class)*100;
         end
       case 'ChiKNN'
         for i = 1:maxPCA         
           [SR_aux(i),~] = KNN(datPCA(indTest,1:i),datPCA(indTrain,1:i),groups(indTrain),groups(indTest),dist,1);
         end
    end
    
    n = find(SR_aux == max(SR_aux),1);
    
    [~,dataBasePCA] = princomp([training;sample]); % after the optimal number of scores is determined, the PCA final scores are computed using the entire database (training and testing)
    trainingPCA = dataBasePCA(1:nl,1:n);           
    testingPCA = dataBasePCA(nl+1:end,1:n);           