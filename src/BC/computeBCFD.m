function FD = computeBCFD(img)
    [nl,nc] = size(img);
    C = zeros(nl,nc,256); % assuming 256 gray levels
    
    % Preventing values out of the range 0-255
    img = max(img,zeros(nl,nc));
    img = min(img,255*ones(nl,nc));
    
    for i = 1:nl
        for j = 1:nc
            C(i,j,img(i,j)+1) = 1;
        end
    end

    [n,r] = boxcount(C);
    p = polyfit(log(r),log(n),1);
    FD = -p(1);
end