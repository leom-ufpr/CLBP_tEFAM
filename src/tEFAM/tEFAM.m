function [out,V] = tEFAM(v,W,Xmem,Ymem,X,paramE,paramF,paramT)

V = hiddenNeurons(v,W,Xmem,X,paramE);  
Z = funF(V,paramF{:});
out = supT(Ymem,Z,@T,paramT);

end

function [Z] = hiddenNeurons(v,W,Xmem,X,paramE)

    Z = Ew(Xmem,X,W,@funE,paramE);
    if(~isempty(v))
        v = reshape(v,length(v),1);
        V = spdiags(v,0,length(v),length(v));
        Z = V*Z;
    end
    
end