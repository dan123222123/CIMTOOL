function [Db,Ds] = build_sploewner_data(M,ell,r,sigma,K)

    D = zeros(ell*K,r*(K+1));
    for k=1:K
        for i=1:k
            D((k-1)*ell+1:k*ell,(i-1)*r+1:i*r) = M(:,:,k+i-1);
            D((i-1)*ell+1:i*ell,k*r+1:(k+1)*r) = M(:,:,k+i);
        end
    end

    if sigma == Inf
        Db = D(1:K*ell,1:K*r);
        Ds = D(1:K*ell,r+1:(K+1)*r);
    else
        Db = D(1:K*ell,r+1:(K+1)*r);
        Ds = sigma*D(1:K*ell,r+1:(K+1)*r) + D(1:K*ell,1:K*r);
    end

end

