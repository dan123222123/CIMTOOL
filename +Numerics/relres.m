function rr = relres(T,ew,ev)
    m = length(ew); rr = zeros(m,1);
    for j = 1:m
        cew = ew(j);
        cev = ev(:,j)/norm(ev(:,j));
        ceval = T(cew);
        rr(j) = norm(ceval*cev)/norm(ceval,"fro");
    end
end

