function G = ihml(z,n,ew,B,C)
    G = 0;
    for i = 1:n
        G = G + (C(:,i)*B(i,:))/(z - ew(i));
    end
end