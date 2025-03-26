function nres = nresidues(C,B)
    n = size(C,2);
    nres = zeros(n,1);
    for i=1:n
        nres(i) = norm(C(:,i)*B(i,:));
    end
end

