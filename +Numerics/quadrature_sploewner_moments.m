function M = quadrature_sploewner_moments(Q,sigma,z,w,K)

    N = size(Q,3);

    if sigma == Inf
        f = @(k,z) (z.^k);
    else
        f = @(k,z) (((-1).^k)/(sigma - z).^(k+1));
    end

    M = zeros(size(Q,1),size(Q,2),K);
    
    for k=1:K
        for n=1:N
            M(:,:,k) = M(:,:,k) + w(n) * f(k-1,z(n)) * Q(:,:,n);
        end
    end

end
