function DV = distMATEuclidean(trains, test)

[train_row, train_col] = size(trains);
[test_row, test_col] = size(test);

testExtend = repmat(test, train_row, 1);
subMatrix = trains-testExtend;
subMatrix2 = subMatrix.^2;

DistMat = subMatrix2;
DV = sqrt(sum(DistMat,2));