function class = KNN(sample,training,group,dist,K)

switch dist
    case 'E' % Euclidean
        [~,I] = pdist2(training,sample,'euclidean','Smallest',K);
        class = group(I);
    case 'C' % chi-square
        [~,I] = pdist2(training,sample,@distMATChiSquare,'Smallest',K);
        class = group(I);        
    case 'K' % Kullback (Fourier)
        [~,I] = pdist2(training,sample,@distMATKullback,'Smallest',K);
        class = group(I);        
    case 'G' % especific for Gabor descriptors
        [~,I] = pdist2(training,sample,@distMATGabor,'Smallest',K);
        class = group(I);        
    case 'L1' % L1 distance
        [~,I] = pdist2(training,sample,'cityblock','Smallest',K);
        class = group(I);
end