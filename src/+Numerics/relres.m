function rr = relres(T,ew,ev)
    orig_state = warning; warning('off','all');
    m = length(ew); rr = zeros(m,1);
    for j = 1:m
        rr(j) = norm(T(ew(j))*(ev(:,j)/norm(ev(:,j))))/norm(T(ew(j)),"fro");
    end
    warning(orig_state);
end

