function mres = maxrelresidual(T,ew,ev)
    m = length(ew);
    relres = zeros(m,1);
    for j = 1:m
        cew = ew(j);
        % normalize the ev
        cev = ev(:,j)/norm(ev(:,j));
        ceval = T(cew);
        relres(j) = norm(ceval*cev)/norm(ceval,"fro");
    end
    mres = max(relres(j));
end