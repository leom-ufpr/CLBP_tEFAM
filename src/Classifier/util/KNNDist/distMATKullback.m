% Kullback distance
function DV = distMATKullback(test,trains)

train_row = size(trains,1);

testExtend = repmat(test, train_row, 1);
%subMatrix = log(testExtend./trains); % F�rmula na Wikipedia
%subMatrix2 = testExtend.*subMatrix;
subMatrix2 = (testExtend./trains)+(trains./testExtend) - 2*ones(train_row,length(test));% F�rmula usada na refer�ncia original de descritores de Fourier, a menos de constantes

DistMat = subMatrix2;
DV = sum(DistMat,2);