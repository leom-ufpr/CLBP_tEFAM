% Specific distance used in Gabor features (assuming that the mean and deviation are interlaces in the vector)
function DV = distMATGabor(test,trains)

train_row = size(trains,1);

testExtend = repmat(test, train_row, 1);

muTr = trains(:,1:2:end);
stdTr = trains(:,2:2:end);
muTs = testExtend(:,1:2:end);
stdTs = testExtend(:,2:2:end);

DistMat = abs((muTs-muTr)./repmat(std([muTr;muTs]),train_row,1)) + abs((stdTs-stdTr)./repmat(std([stdTr;stdTs]),train_row,1)); % fórmula da referência original

DV = sum(DistMat,2);