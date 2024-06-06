function [Z] = T(X,Y,type,varargin)

switch type    
    case 1 %min
        Z = min(X,Y);
        
    case 2 %produto
        Z = X.*Y;
        
    case 3 %Lukasiewicz
        Z = max(0,X+Y-1);
        
    case 4 %Yager 0<p<+\infty
        p = varargin{1};
        Z = max(0,1 - ((1-X).^p + (1-Y).^p).^(1/p));
        
    otherwise %min
        Z = min(X,Y);
end