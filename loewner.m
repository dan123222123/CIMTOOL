function [E,V] = loewner(qs,f,z,w,m,maxK)
% Suppose T : C -> nXn matrices is meromorphic on a domain D.
% The boundary of D is a closed curve in C approximated with {z_k,w_k}
% nodes and weights associated to a particular quadrature rule.
% INPUTS
%   qs -- vector of two-sided samples of L*T^{-1}R at z_k in z
%   f -- function from ZxC -> C that is analytic on D
%   z -- points on C (coming from some quadrature rule)
%   w -- quadrature weights associated to z
%   m -- number of poles of T in D
%   maxK -- max number of moments to use in construction of data matrices
% OUTPUTS
%   E -- mXm matrix of eigenvalues of T within D
%   V -- nXm matrix of eigenvectors of T corresponding to E
% BEGIN

% BEGIN SANITY CHECKS
% check that elements of qs have the same dimension
[ell,r,N] = size(qs);
for i=1:N
    assert(all(size(qs(:,:,i))==[ell,r]));
end

% check that the length of qs, z, and w match
assert(N==length(z));
assert(N==length(w));

% check that m <= n -- we can't find more than n poles of T!
assert(m <= n);
% END SANITY CHECKS

% BEGIN NUMERICS

% extract shift from f(k,z)
sigma = 1/feval(0,0)

% allocate maximum size moment and data matrix
M = zeros(ell,r,maxK);
D = zeros(ell*maxK,r*(maxK+1));

kb=0;
for k=1:maxK
    % construct kth moment
    for n=1:N
        M(:,:,k) = M(:,:,k) + w(n) * feval(f,k,z(n)) * qs(:,:,n);
    end
    % update kth block-row/column of D (overwrites diagonals, but wtv)
    for i=1:k
        D((i+k-2)*ell+1:(i+k-1)*ell,(i-1)*r+1:i*r) = M(:,:,k+i-1);
        D((i-1)*ell+1:i*ell,(i+k-2)*r+1:(i+k-1)*r) = M(:,:,k+i-1);
    end
    
    % TODO
    
end

% END NUMERICS

end