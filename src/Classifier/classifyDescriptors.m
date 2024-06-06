% K-fold cross validation
% Input: dat = feature matrix (group IDs in the last column)
%        method = 'SVM','LDA','KNN' (default K=1)
% Optional Input: crossVal = 'KFold' (K=5 - default), 'HoldOut' (0.5/0.5)
%                 strat = 0 (random - defaut), 1 (stratified)
%                 PCA = 0 (no PCA - default), 1 (PCA scores - number of scores determined by training holdout)
%                 Fscore = 0 (no feature selection - default), 1 (SVM+FScore feature selection)
%                 dist = type of distance for KNN classifier ('C' (default),'E','L','K','G','L1')
function [SR,error,CM,prob,classes] = classifyDescriptors(dat,method,varargin)  
  
  % Parsing optional input:
  options = struct('crossVal','KFold','strat',0,'PCA',0,'FScore',0,'dist','C');
  optionNames = fieldnames(options);
  nArgs = length(varargin);
  if round(nArgs/2)~=nArgs/2
     error('Optional arguments are propertyName/propertyValue pairs')
  end
  for pair = reshape(varargin,2,[]) %# pair is {propName;propValue}
     inpName = pair{1}; %# make case insensitive
     if any(strcmp(inpName,optionNames))
        options.(inpName) = pair{2};
     else
        error('%s is not a recognized parameter name',inpName)
     end
  end 
  
  switch options.crossVal
    case 'KFold'
      [SR,error,CM,prob,classes] = KFoldClassify(dat,method,options.strat,options.PCA,options.FScore,options.dist);
    case 'HoldOut'
      [SR,error,CM,prob] = HoldOutClassify(dat,method,options.strat,options.PCA,options.FScore,options.dist);
  end