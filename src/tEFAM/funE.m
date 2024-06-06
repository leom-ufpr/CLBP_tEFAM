function [Z] = funE(X,Y,type,paramE)

epsilon = 10^(-8);
switch type
    
    case 1 %E_\lamda
        Lambda = paramE(1);
        Len = paramE(2);
        aux = Lambda*Len;
        if(aux > epsilon)
            Z = abs(X - Y);
            Z = max(0, 1 - (Z./aux));
        else
            Z = ones(size(X));
        end
        
    case 2 % G_\sigma
        sigma = paramE(1);  
        if(sigma > epsilon)
            Z = exp(-((X-Y).^2/(sigma^2)));
        else
            Z = ones(size(X));
        end
        
    case 3 %H_\sigma
        sigma = paramE(1);
        if(sigma > epsilon)
            Z = exp(-sigma*abs(X-Y));
        else
            Z = ones(size(X));
        end
        
    case 4 %(Sandra approach) with 3 fuzzy sets
        type = paramE(1);
        base = paramE(2:end);
        switch type
            case 0 %triangular                
                %A1 e A3
                if(base(3) ~= base(1))
                    fa = @(x) (x - base(1))./(base(3) - base(1));
                    fb = @(x) (base(3) - x)./(base(3) - base(1));
                else
                    fa = @(x) 1; fb = @(x) 1;                    
                end
                A1 = @(x) max(min(1,fb(x)),0);
                A3 = @(x) max(min(1,fa(x)),0);
                
                if(base(2) ~= base(1))
                    fa = @(x) (x - base(1))./(base(2) - base(1));
                else
                    fa = @(x) 1;
                end
                if(base(3) ~= base(2))
                    fb = @(x) (base(3) - x)./(base(3) - base(2));
                else
                    fb = @(x) 1;                    
                end
                A2 = @(x) max(min(fa(x),fb(x)),0);                
                
                
            case 1 %trapezoidal
                
                %A1
                if(base(2) ~= base(3))
                    fb = @(x) (base(3) - x)./(base(3) - base(2));
                else
                    fb = @(x) 1;                    
                end
                A1 = @(x) max(min(1,fb(x)),0);
                
                %A2
                if(base(2) ~= base(3))
                    fa = @(x) (x - base(2))./(base(3) - base(2));
                else
                    fa = @(x) 1;
                end
                if(base(5) ~= base(4))
                    fb = @(x) (base(5) - x)./(base(5) - base(4));
                else
                    fb = @(x) 1;                    
                end
                A2 = @(x) min(1,max(min(fa(x),fb(x)),0));
                
                %A3
                if(base(4) ~= base(5))
                    fa = @(x) (x - base(4))./(base(5) - base(4));
                else
                    fa = @(x) 1;
                end
                A3 = @(x) max(min(fa(x),1),0);
        end
        Z =  max(max(min(A1(X),A1(Y)),min(A2(X),A2(Y))),min(A3(X),A3(Y)));
        P = (Z  > epsilon);
        Z1 = abs(A1(X) - A1(Y)); 
        Z2 = abs(A2(X) - A2(Y));
        Z3 = abs(A3(X) - A3(Y));
        Z(P) = min(min(1-Z1(P), 1-Z2(P)), 1-Z3(P));
        
end