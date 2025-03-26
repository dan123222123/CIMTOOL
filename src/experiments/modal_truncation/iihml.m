function G = iihml(z,n,ew,B,C)
    % T = pinv(C); C = pinv(B); B = T; 
    G = 0;
    for i = 1:n
        G = G + (C(:,i)*B(i,:))/(z - ew(i));
    end
    G = pinv(G);
end