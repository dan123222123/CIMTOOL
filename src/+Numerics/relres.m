function rr = relres(T,ew,ev,mode)
    orig_state = warning; warning('off','all');
    % need to normalize eigenvectors!!!
    if mode == Numerics.SampleMode.Inverse
        rrf = @(i) norm(T(ew(i))*(ev(:,i)/norm(ev(:,i)))) / norm(T(ew(i)),"fro");
    else
        rrf = @(i) norm(T(ew(i))\(ev(:,i)/norm(ev(:,i)))) / norm(inv(T(ew(i))),"fro");
    end
    m = length(ew); rr = zeros(m,1);
    for j = 1:m
        rr(j) = rrf(j);
    end
    warning(orig_state);
end
