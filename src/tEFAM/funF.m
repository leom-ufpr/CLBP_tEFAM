function [Z] = funF(X,type,paramF)

switch type
    
    case 0 %limita entre 0 e 1
        Z = min(1,max(0,X));
    case 1 % win take all (Maxnet)
        Z = double(X >= repmat(max(X,[],1),[size(X,1) 1]));
    case 2 %Normaliza
        Z = X - repmat(min(X,[],1),[size(X,1) 1]);
        Z = Z*spdiags(max(Z,[],1)',0,size(X,2),size(X,2));    
end