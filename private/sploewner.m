function [E,sv] = sploewner(Qlr,sigma,z,w,m,maxK,abstol)
% Suppose T : C -> nXn matrices is meromorphic on a domain D.
% The boundary of D is a closed curve in C approximated with {z_k,w_k}
% nodes and weights associated to a particular quadrature rule.
% INPUTS
%   Qlr     -- vector of two-sided samples L*T^{-1}R at z_k in z
%   sigma   -- shift for moment calculation, can be finite or Inf
%   z       -- points on C (coming from some quadrature rule)
%   w       -- quadrature weights associated to z
%   m       -- number of poles of T in D
%   maxK    -- max number of moments to use in construction of data 
%              matrices should be >=1
%   abstol  -- absolute tolerance for rank determination of base data matrix
% OUTPUTS
%   E       -- mXm matrix of eigenvalues of T within D
% BEGIN

% BEGIN SANITY CHECKS
% check that elements of qs have the same dimension
[ell,r,N] = size(Qlr);
for i=1:N
    assert(all(size(Qlr(:,:,i))==[ell,r]));
end

% check that the length of qs, z, and w match
assert(N==length(z));
assert(N==length(w));
% END SANITY CHECKS

% BEGIN NUMERICS
% allocate maximum size moment and data matrix
M = zeros(ell,r,2*maxK);
D = zeros(ell*maxK,r*(maxK+1));

% choose "hankel" or "loewner" moment functions based on shift finite/Inf
if sigma == Inf
    f = @(k,z) (z.^k);
else
    f = @(k,z) ((-1.^k)/(sigma - z).^(k+1));
end

kb=0; % which moment the data matrix reaches sufficient rank at
for k=1:maxK
    % construct (k+1)-st moment
    for n=1:N
        M(:,:,2*k-1) = M(:,:,2*k-1) + w(n) * f(2*k-2,z(n)) * Qlr(:,:,n);
        M(:,:,2*k) = M(:,:,2*k) + w(n) * f(2*k-1,z(n)) * Qlr(:,:,n);
    end
    % update k-th block-row and (k+1)-st block-column of D
    for i=1:k
        D((k-1)*ell+1:k*ell,(i-1)*r+1:i*r) = M(:,:,k+i-1);
        D((i-1)*ell+1:i*ell,k*r+1:(k+1)*r) = M(:,:,k+i);
    end
    % if rank(Db) > m, we don't need to continue padding the data matrix
    if ~isnan(abstol)
        Drank = rank(D(1:k*ell,1:k*r),abstol);
    else
        Drank = rank(D(1:k*ell,1:k*r));
    end

    if Drank >= m
        kb=k;
        break;
    end
end

if kb==0
    error("could not generate rank %d base data matrix",m);
end

% extract data matrix from D
D0 = D(1:k*ell,1:k*r);

% construct base and shifted data matrix based on sigma and D
if sigma == Inf
    D1 = D(1:k*ell,r+1:(k+1)*r);
else
    D0 = -1*D0;
    D1 = -sigma*D(1:k*ell,r+1:(k+1)*r) - D0;
end

% (reduced) rank-m svd of D0
[X, Sigma, Y] = svd(D0,"matrix");
sv = diag(Sigma)/Sigma(1,1);

% solve (X'*D1*Y,Sigma) GEP to get eigenvalues of underlying NLEVP in D.
X=X(:,1:m); Sigma=Sigma(1:m,1:m); Y=Y(:,1:m);
E = eig(X'*D1*Y,Sigma);
% END NUMERICS

end