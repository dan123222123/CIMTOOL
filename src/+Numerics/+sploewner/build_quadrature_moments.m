function [Ml,Mr,Mlr] = build_quadrature_moments(sigma,z,w,Ql,Qr,Qlr,K)

    [ell,r,N] = size(Qlr); n = size(Qr,1);

    if sigma == Inf
        f = @(k,z) (z.^k);
    else
        f = @(k,z) (((-1).^k)/(sigma - z).^(k+1));
    end

    Mlr = zeros(ell,r,2*K); Mr = zeros(n,r,K); Ml = zeros(ell,n,K);
    
    for k=1:K
        for nn=1:N
            Mlr(:,:,2*k-1) = Mlr(:,:,2*k-1) + w(nn) * f(2*k-2,z(nn)) * Qlr(:,:,nn);
            Mlr(:,:,2*k) = Mlr(:,:,2*k) + w(nn) * f(2*k-1,z(nn)) * Qlr(:,:,nn);
            Mr(:,:,k) = Mr(:,:,k) + w(nn) * f(k-1,z(nn)) * Qr(:,:,nn);
            Ml(:,:,k) = Ml(:,:,k) + w(nn) * f(k-1,z(nn)) * Ql(:,:,nn);
        end
    end

end
