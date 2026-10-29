function [Ml,Mr,Mlr] = build_quadrature_moments(sigma,z,w,Ql,Qr,Qlr,K,ell,r)
% Helper function to build generalized moments up to order K from left/right/two-sided quadrature samples at nodes \( z \) using quadrature weights \( w \).
% Only the leading ell left and r right directions of the samples are used.

    if nargin < 8, ell = size(Qlr,1); end
    if nargin < 9, r = size(Qlr,2); end
    N = size(Qlr,3); n = size(Qr,1);

    if sigma == Inf
        f = @(k,z) (z.^k);
    else
        f = @(k,z) (((-1).^k)/(sigma - z).^(k+1));
    end

    Mlr = zeros(ell,r,2*K); Mr = zeros(n,r,K); Ml = zeros(ell,n,K);

    for k=1:K
        for nn=1:N
            Mlr(:,:,2*k-1) = Mlr(:,:,2*k-1) + w(nn) * f(2*k-2,z(nn)) * Qlr(1:ell,1:r,nn);
            Mlr(:,:,2*k) = Mlr(:,:,2*k) + w(nn) * f(2*k-1,z(nn)) * Qlr(1:ell,1:r,nn);
            Mr(:,:,k) = Mr(:,:,k) + w(nn) * f(k-1,z(nn)) * Qr(:,1:r,nn);
            Ml(:,:,k) = Ml(:,:,k) + w(nn) * f(k-1,z(nn)) * Ql(1:ell,:,nn);
        end
    end

end
