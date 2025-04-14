function [Db,Ds,B,C] = build_sploewner(sigma,Ml,Mr,Mlr,K)
% Helper function to build the data matrices for SPLoewner realization.

    [ell,r,~] = size(Mlr); n = size(Mr,1);

    D = zeros(ell*K,r*(K+1));
    B = zeros(ell*K,n); C = zeros(n,r*K);

    % construction left/right data matrices
    for k=1:K
        for i=1:k
            D((k-1)*ell+1:k*ell,(i-1)*r+1:i*r) = Mlr(:,:,k+i-1);
            D((i-1)*ell+1:i*ell,k*r+1:(k+1)*r) = Mlr(:,:,k+i);
        end
        B((k-1)*ell+1:k*ell,:)  = Ml(:,:,k);
        C(:,(k-1)*r+1:k*r)      = Mr(:,:,k);
    end

    % construct base and shifted data matrix
    if sigma == Inf
        Db = D(1:K*ell,1:K*r);
        Ds = D(1:K*ell,r+1:(K+1)*r);
    else
        Db = D(1:K*ell,r+1:(K+1)*r);
        Ds = sigma*D(1:K*ell,r+1:(K+1)*r) + D(1:K*ell,1:K*r);
    end

end
