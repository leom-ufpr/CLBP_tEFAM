% Fisher-score + SVM feature selection used for multifractal descriptors  
function indF = applyFScore(training,groups)
    
classLabels = unique(groups);
nFeatures = size(training,2); % number of features

score = zeros(1,nFeatures);
for i = 1:length(classLabels)
    score = score + FScore(training,groups==classLabels(i));
end
[~,ind] = sort(score(~isnan(score)),'descend');

% SVM cross-validation
for i = 1:length(ind)
    for j = 1:5
        [SR_aux(j),~,~,~] = HoldOutClassify([training(:,ind(1:i)) groups],'SVM',0,0,0,'C');
    end
    SR(i) = mean(SR_aux);
end
newNFeatures = find(SR==max(SR),1);
indF = ind(1:newNFeatures);
%==========================================================================
% Assuming group labels  = 1 and 0
function F = FScore(training,groups)

nFeatures = size(training,2);
for i = 1:nFeatures
    xi0 = training(groups==0,i);
    xi1 = training(groups==1,i);
    xi = training(:,i);
    n1 = sum(groups==1);
    n0 = sum(groups==0);
    F(i) = (mean(xi1)-mean(xi))^2 + (mean(xi0)-mean(xi))^2;
    F(i) = F(i) / ((1/(n1-1))*sum((xi1 - repmat(mean(xi1),n1,1)).^2) + (1/(n0-1))*sum((xi0 - repmat(mean(xi0),n0,1)).^2));
end