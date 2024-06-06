function DV = distMATLog(trains, test)

[train_row, train_col] = size(trains);
[test_row, test_col] = size(test);

trainsN = trains./repmat(sum(trains,2),1,train_col); % normalization
testN = test./repmat(sum(test,2),1,test_col);

testExtend = repmat(testN, train_row, 1);
%subMatrix = testExtend.*log(trainsN+10^(-6));
subMatrix = testExtend.*log(trainsN);

DistMat = subMatrix;
DV = sum(DistMat,2);