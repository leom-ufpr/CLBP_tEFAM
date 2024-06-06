function CR = SVM_KFold(dat)

%K-Fold:
nFold = 10;
[nl nc] = size(dat);
indices = kfold(nFold,nl);

for i = 1:nFold
    indTest = find(indices == i); indTrain = setdiff([1:nl],indTest);
    [acerto,~,~] = multisvm_fold_externo([dat(indTrain,:) dat(indTrain,end)],[dat(indTest,:) dat(indTest,end)]);
    acerto_aux(i) = acerto;
end

CR = mean(acerto_aux);
%==========================================================================
% K-fold de n amostras
function kvector = kfold(k,n)

d = ceil(n/k);
kvector = repmat([1:k],1,d);
kvector = kvector(1:n);
