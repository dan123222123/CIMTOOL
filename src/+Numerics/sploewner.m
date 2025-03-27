function [Lambda,V,W,Db,Ds,B,C,X,Sigma,Y] = sploewner(z,w,Qlr,Ql,Qr,sigma,m,K,abstol)
% Hankel/Single Point Loewner realization with two-sided quadrature samples.
% Given two-sided/left/right quadrature data `Qlr'/`Ql`/`Qr`, construction moments via contour integration approximated by a quadrature rule with nodes and weights \( ( z_k, w_k ) \).
arguments (Input) % NOTE/TODO -- it is possible to write validation functions so that the we can get some more robust code.
    z                % vector of quadrature nodes
    w                % vector of quadrature weights
    Qlr              % vector of two-sided samples \( L^* T^{-1} R \) at \( z_k \) in \(z\)
    Ql               % vector of left-sided samples \( L^* T^{-1} \) at \( z_k \) in \(z\)
    Qr               % vector of right-sided samples of \( T^{-1} R \) at \( z_k \) in \(z\)
    sigma            % shift value -- \( \infty \Rightleftarrow \) Hankel, \( < \infty \Leftrightarrow \) SPLoewner
    m                % number of poles to search for in \( \Omega \)
    K                % number of moments to use in data matrix construction
    abstol  = NaN    % absolute tolerance for base data matrix rank determination
end
arguments (Output)
    Lambda           % diagonal eigenvalue matrix
    V
    W
    Db
    Ds
    B
    C
    X
    Sigma
    Y
end

% check that elements of qs have the same dimension
[ell,r,N] = size(Qlr);
n = size(Qr,1);
for i=1:N
    assert(all(size(Qlr(:,:,i))==[ell,r]));
end

% check that the length of qs, z, and w match
assert(N==length(z)); assert(N==length(w));

% check that m, # of left/right shifts are greater than 0
assert(m > 0, "# Eig Search should be > 0");
assert(K > 0, "# of moments should be > 0");

% allocate maximum size moment and data matrix
Mlr = zeros(ell,r,2*K); Mr = zeros(n,r,K); Ml = zeros(ell,n,K);
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
        Mr(:,:,k) = Mr(:,:,k) + w(nn) * f(k-1,z(nn)) * Qr(:,:,nn);
        Ml(:,:,k) = Ml(:,:,k) + w(nn) * f(k-1,z(nn)) * Ql(:,:,nn);
    end
    % update k-th block-row and (k+1)-st block-column of D
    for i=1:k
        D((k-1)*ell+1:k*ell,(i-1)*r+1:i*r) = Mlr(:,:,k+i-1);
        D((i-1)*ell+1:i*ell,k*r+1:(k+1)*r) = Mlr(:,:,k+i);
    end
end

% extract data matrix from D
Db = D(1:K*ell,1:K*r);

% construct base and shifted data matrix
if sigma == Inf
    Ds = D(1:K*ell,r+1:(K+1)*r);
else
    Db = D(1:K*ell,r+1:(K+1)*r);
    Ds = sigma*D(1:K*ell,r+1:(K+1)*r) + D(1:K*ell,1:K*r);
end

% construction left/right data matrices
B = zeros(size(Ml,1)*K,size(Ml,2));
C = zeros(size(Mr,1),size(Mr,2)*K);
for i=1:K
    B((i-1)*size(Ml,1)+1:i*size(Ml,1),:) = Ml(:,:,i);
    C(:,(i-1)*size(Mr,2)+1:i*size(Mr,2)) = Mr(:,:,i);
end

[Lambda,V,W,X,Sigma,Y] = Numerics.realize(m,Db,Ds,B,C,abstol);

end