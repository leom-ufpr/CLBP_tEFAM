function [Z] = supT(X,Y,T,paramT)

[k nx] = size(X);
ny = size(Y,2);
Z = [];

total_mem = 0.25*10^9;%3GB
num_div =  ceil(size(X,1)*size(X,2)*8*ny/total_mem);
step = ceil(ny/num_div);


for j=0:step:(ny-1)
    
    idx = (j+1):min(j+step,ny);
    nidx = length(idx);
    
    X2 = repmat(X, [1 1 nidx]);
    Yaux(1,:,:) = Y(:,idx);
    Y2 = repmat(Yaux,[k 1 1]);
    
    Z2 = T(X2,Y2,paramT{:});
    P2 = max(Z2,[],2);
    Z = [Z reshape(P2,k,nidx)];
    clear Yaux;
end

end