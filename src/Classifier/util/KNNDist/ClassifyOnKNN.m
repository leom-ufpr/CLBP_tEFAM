function [CP,classes_out] = ClassifyOnKNN(DM,trainClassIDs,testClassIDs,K)

if nargin<4
    disp('Not enough input parameters.')
    return
end

rightCount = 0;
for i=1:length(testClassIDs);
    [~, index]= sort(DM(i,:));   % find Nearest Neighborhood
    if mode(trainClassIDs(index(1:K))) == testClassIDs(i)  % judge whether the nearest one is correctly classified
        rightCount = rightCount+1;
    end
    classes_out(i) = mode(trainClassIDs(index(1:K)));
end
CP = rightCount/length(testClassIDs)*100;