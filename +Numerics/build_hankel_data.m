function [Hb,Hs] = build_hankel_data(T,L,R)

% allocate maximum size moment and data matrix
Mlr = zeros(ell,r,2*K);
Mr = zeros(n,r,K);
D = zeros(ell*K,r*(K+1));

% choose "hankel" or "loewner" moment functions based on shift finite/Inf
if sigma == Inf
    f = @(k,z) (z.^k);
else
    f = @(k,z) (((-1).^k)/(sigma - z).^(k+1));
end

for k=1:K
    % construct (k+1)-st moments
    for nn=1:N
        Mlr(:,:,2*k-1) = Mlr(:,:,2*k-1) + w(nn) * f(2*k-2,z(nn)) * Qlr(:,:,nn);
        Mlr(:,:,2*k) = Mlr(:,:,2*k) + w(nn) * f(2*k-1,z(nn)) * Qlr(:,:,nn);
        Mr(:,:,k) = Mr(:,:,k) + w(nn) * f(k,z(nn)) * Qr(:,:,nn);
    end
    % update k-th block-row and (k+1)-st block-column of D
    for i=1:k
        D((k-1)*ell+1:k*ell,(i-1)*r+1:i*r) = Mlr(:,:,k+i-1);
        D((i-1)*ell+1:i*ell,k*r+1:(k+1)*r) = Mlr(:,:,k+i);
    end

end

% extract data matrix from D
D0 = D(1:K*ell,1:K*r);

% construct base and shifted data matrix based on sigma and D
if sigma == Inf
    D1 = D(1:K*ell,r+1:(K+1)*r);
else
    D0 = D(1:K*ell,r+1:(K+1)*r);
    D1 = sigma*D(1:K*ell,r+1:(K+1)*r) + D(1:K*ell,1:K*r);
end
end
