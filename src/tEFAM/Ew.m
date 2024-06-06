function [Z] = Ew(X,Y,w,E,paramE)

[natt nx] = size(X);
ny = size(Y,2);
 
total_mem = 0.25*10^9;
num_div =  ceil(size(Y,1)*size(Y,2)*8*nx/total_mem);
step = ceil(ny/num_div);
Z=[];

pesos = cell(1,natt);
nw = size(w,2);
for j=1:natt 
    pesos{j} =  spdiags(w(j,:)',0,nw,nw);
end

Xaux(:,1,:) = X';
    
for j=0:step:(ny-1)
    
    idx = (j+1):min(j+step,ny);
    nidx = length(idx);
    
    X2 = repmat(Xaux, [1, nidx, 1]);
    Yaux(1,:,:) = Y(:,idx)';
    Y2 = repmat(Yaux,[nx 1 1]);
    
    z2=[];
    for i=1:natt
       if(iscell(E)) 
           v = E{i}(X2(:,:,i),Y2(:,:,i),paramE{i,1},paramE{i,2});
           z2(:,:,i) = pesos{i}*v;
       else
           aux = paramE{2};
           v = E(X2(:,:,i),Y2(:,:,i),paramE{1},aux(i,:));
           z2(:,:,i) = pesos{i}*v;
       end        
    end
    
    p2 = sum(z2,3);
    Z = [Z p2];
    clear Yaux;
    
end
