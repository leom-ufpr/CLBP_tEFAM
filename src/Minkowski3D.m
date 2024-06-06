% Bouligand-Minkowski fractal descriptors
function [logx,logy] = Minkowski3D(img,rmax)

img = double(img);
[nl,nc] = size(img);
B = zeros(nl+2*rmax,nc+2*rmax,256+2*rmax); % assuming that the image has 256 gray levels

for i = 1:nl
    for j = 1:nc
        B(i+rmax,j+rmax,img(i,j)+1+rmax) = 1;
    end
end

D = bwdist(B);
u = sort(unique(D(D(:)~=0 & D(:)<=rmax)));
r = 1;
for r = 1:length(u)
    N(r) = sum(D(:) <= u(r));
    x(r) = u(r);
    r = r+1;
end

logx = log(x);
logy = log(N);