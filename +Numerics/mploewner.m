function [Lambda,V,Lbsw,Lssw,Lb,Ls] = mploewner(Ql,Qr,theta,sigma,L,R,z,w,m,abstol)
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
[Lsize,n1,N1] = size(Ql);
[n2,Rsize,N2] = size(Qr);
elltheta = length(theta);
rsigma = length(sigma);

% check that the dimensions of the samples are compatible
assert(n1==n2);
assert(N1==N2);
n=n1; N=N1;

% check that the length of qs, z, and w match
assert(N==length(z));
assert(N==length(w));

% check that m, # of left/right shifts are greater than 0
assert(m > 0, "# Eig Search should be > 0");
assert(elltheta > 0 && rsigma > 0, "# of left/right shifts should be > 0");
% END SANITY CHECKS

% BEGIN NUMERICS
% allocate left/right data and base/shifted Loewner matrices
B = zeros(elltheta,n); C = zeros(n,rsigma);
Lb = zeros(elltheta,rsigma); Ls = zeros(elltheta,rsigma);

% construct B and C matrices
for i=1:elltheta
    for k=1:N
        ldir = mod(i-1,Lsize)+1;
        B(i,:) = B(i,:) + (w(k)/(theta(i)-z(k)))*Ql(ldir,:,k);
    end
end

for j=1:rsigma
    for k=1:N
        rdir = mod(j-1,Rsize)+1;
        C(:,j) = C(:,j) + (w(k)/(sigma(j)-z(k)))*Qr(:,rdir,k);
    end
end

% construct Lb and Ls matrices
for i=1:elltheta
    for j=1:rsigma
        ldir = mod(i-1,Lsize)+1;
        rdir = mod(j-1,Rsize)+1;
        Lb(i,j) = (B(i,:)*R(:,rdir) - L(:,ldir)'*C(:,j))/(theta(i)-sigma(j));
        Ls(i,j) = (theta(i)*B(i,:)*R(:,rdir) - sigma(j)*L(:,ldir)'*C(:,j))/(theta(i)-sigma(j));
    end
end

[Lbrank,X,Sigma,Y,Lbsw] = rankdet;

if Lbrank < m
    error("generated rank %d < %d data matrix",Lbrank,m);
end

% solve (X'*D1*Y,Sigma) GEP to get eigenvalues of underlying NLEVP in D.
X=X(:,1:m); Sigma=Sigma(1:m,1:m); Y=Y(:,1:m);
M = X'*Ls*Y / Sigma;
[S,Lambda] = eig(M);
Lambda = diag(Lambda);
V = C*Y*(Sigma\S); % recover right eigenvectors from right-sided samples

Lssw = svd(Ls);
Lssw = Lssw / Lssw(1);
% END NUMERICS

    function [Lbrank,X,Sigma,Y,Lbsw] = rankdet
        [X, Sigma, Y] = svd(Lb,"matrix");
        if isnan(abstol)
            tol = max(size(Sigma))*eps(Sigma(1,1));
        else
            tol = abstol;
        end
        Lbsw = diag(Sigma)/Sigma(1,1);
        Lbrank = sum(diag(Sigma)>=tol);
    end

end