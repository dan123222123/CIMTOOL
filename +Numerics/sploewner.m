function [Lambda,V,W,Db,Ds,B,C,X,Sigma,Y] = sploewner(Qlr,Qr,Ql,sigma,z,w,m,K,abstol)
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
%   abstol -- absolute tolerance for base data matrix rank determination
% OUTPUTS
%   E       -- mXm matrix of eigenvalues of T within D
%   Dbsw    -- singular valuse of base data matrix
% BEGIN

% BEGIN SANITY CHECKS
% check that elements of qs have the same dimension
[ell,r,N] = size(Qlr);
n = size(Qr,1);
for i=1:N
    assert(all(size(Qlr(:,:,i))==[ell,r]));
end

% check that the length of qs, z, and w match
assert(N==length(z));
assert(N==length(w));

% check that m, # of left/right shifts are greater than 0
assert(m > 0, "# Eig Search should be > 0");
assert(K > 0, "# of moments should be > 0");
% END SANITY CHECKS

% BEGIN NUMERICS
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

% construct base and shifted data matrix based on sigma and D
if sigma == Inf
    Ds = D(1:K*ell,r+1:(K+1)*r);
else
    Db = D(1:K*ell,r+1:(K+1)*r);
    Ds = sigma*D(1:K*ell,r+1:(K+1)*r) + D(1:K*ell,1:K*r);
end

B = zeros(size(Ml,1)*K,size(Ml,2));
C = zeros(size(Mr,1),size(Mr,2)*K);
for i=1:K
    B((i-1)*size(Ml,1)+1:i*size(Ml,1),:) = Ml(:,:,i);
    C(:,(i-1)*size(Mr,2)+1:i*size(Mr,2)) = Mr(:,:,i);
end

[Lambda,V,W,X,Sigma,Y] = Numerics.realize(m,Db,Ds,B,C,abstol);
% END NUMERICS

end