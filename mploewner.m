function E = mploewner(Ql,Qr,theta,sigma,L,R,z,w,m)
% Suppose T : C -> nXn matrices is meromorphic on a domain D.
% The boundary of D is a closed curve in C approximated with {z_k,w_k}
% nodes and weights associated to a particular quadrature rule.
% INPUTS
%   Ql -- vector of left-sided samples L*T^{-1} at z_k in z
%   Qr -- vector of right-sided samples of T^{-1}R at z_k in z
%   theta -- left interpolation points
%   sigma -- right interpolation points
%   L -- nXell matrix of left probing directions
%   R -- nXr matrix of right probing directions
%   z -- points on C (coming from some quadrature rule)
%   w -- quadrature weights associated to z
%   m -- number of poles of T in D
% OUTPUTS
%   E -- mXm matrix of eigenvalues of T within D
% BEGIN

% BEGIN SANITY CHECKS
% check that elements of qs have the same dimension
[ell,n1,N1] = size(Ql);
[n2,r,N2] = size(Qr);

% check that the dimensions of the samples are compatible
assert(n1==n2);
assert(N1==N2);
n=n1; N=N1;

% check that the length of qs, z, and w match
assert(N==length(z));
assert(N==length(w));
% END SANITY CHECKS

% BEGIN NUMERICS
% allocate left/right data and base/shifted Loewner matrices
B = zeros(ell,n); C = zeros(n,r);
Lb = zeros(ell,r); Ls = zeros(ell,r);

% construct B and C matrices
for i=1:ell
    for k=1:N
        B(i,:) = B(i,:) + (w(k)/(theta(i)-z(k)))*Ql(i,:,k);
    end
end
for j=1:r
    for k=1:N
        C(:,j) = C(:,j) + (w(k)/(sigma(j)-z(k)))*Qr(:,j,k);
    end
end

% construct Lb and Ls matrices
for i=1:ell
    for j=1:r
        Lb(i,j) = (B(i,:)*R(:,j) - L(:,i)'*C(:,j))/(theta(i)-sigma(j));
        Ls(i,j) = (theta(i)*B(i,:)*R(:,j) - sigma(j)*L(:,i)'*C(:,j))/(theta(i)-sigma(j));
    end
end

if rank(Lb) < m
    error("could not generate rank %d base Loewner matrix",m);
end

% (reduced) rank-m svd of Lb
[X, Sigma, Y] = svd(Lb,"matrix");
X=X(:,1:m); Sigma=Sigma(1:m,1:m); Y=Y(:,1:m);

% solve (X'*D1*Y,Sigma) GEP to get eigenvalues of underlying NLEVP in D.
E = eig(X'*Ls*Y,Sigma);
% END NUMERICS

end