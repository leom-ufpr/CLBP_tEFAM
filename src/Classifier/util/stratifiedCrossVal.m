function indices = stratifiedCrossVal(classes,type)
  
  K = 5; % default 5-fold
  
  u = unique(classes);
  indices = 1*ones(1,length(classes)); % initialized with ones
  switch type
    case 'HoldOut'
      for i = 1:length(u)
        iClass = u(i);
        indIClass = find(classes == iClass);
        indTrain = indIClass(1:2:end); % odd indices for training
        indTest = indIClass(2:2:end); % even indices for testing
        indices(indTrain) = 1;
        indices(indTest) = 2;        
      end
    case 'KFold'
      for i = 1:length(u)
        iClass = u(i);
        indIClass = find(classes == iClass);
        n = length(indIClass);
        d = ceil(n/K);
        kvector = repmat([1:K],1,d);
        indices(indIClass) = kvector(1:n);
      end      
  end