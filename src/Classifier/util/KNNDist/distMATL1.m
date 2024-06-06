function DV = distMATL1(trains, test)

[train_row, train_col] = size(trains);
[test_row, test_col] = size(test);

testExtend = repmat(test, train_row, 1);
subMatrix = trains-testExtend;
subMatrix2 = abs(subMatrix);

DistMat = subMatrix2;
DV = sum(DistMat,2);