function [CP,class] = KNN_old(sample,training,group_training,group_sample,dist,K)

for i=1:size(sample,1)
    test = sample(i,:);        
    switch dist
        case 'E' % Euclidean
            DM(i,:) = distMATEuclidean(training,test)';
        case 'C' % chi-square
            DM(i,:) = distMATChiSquare(test,training)';
        case 'L' % log
            DM(i,:) = distMATLog(training,test)';  
        case 'K' % Kullback (Fourier)
            DM(i,:) = distMATKullback(training,test)';
        case 'G' % especific for Gabor descriptors
            DM(i,:) = distMATGabor(training,test)';
        case 'L1' % L1 distance
            DM(i,:) = distMATL1(training,test)';
    end
end
[CP,class] = ClassifyOnKNN(DM,group_training,group_sample,K);