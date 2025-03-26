function [Lambda,V,W,Db,Ds,B,C,X,Sigma,Y] = mploewner(Ql,Qr,theta,sigma,L,R,z,w,m,abstol)
% Given left/right quadrature data `Ql`/`Qr`, compute probed left/right transfer function samples at left/right interpolation points (theta/sigma) via contour integration approximated by a quadrature rule with nodes and weights \( ( z_k, w_k ) \).
%
%% Args:
%%   Ql:
%%   Qr: vector of right-sided samples of T^{-1}R at z_k in z
%%   theta: left interpolation points
%%   sigma: right interpolation points
%%   L: nXell matrix of left probing directions
%%   R: nXr matrix of right probing directions
%%   z: points on C (coming from some quadrature rule)
%%   w: quadrature weights associated to z
%%   m: number of poles of T in D
%%   abstol: absolute tolerance for base data matrix rank determination
%%
%% Returns:
%%   E: mXm matrix of eigenvalues of T within D
arguments (Inputs)
    Ql double % vector of left-sided samples L*T^{-1} at z_k in z
    Qr double
    theta double
    sigma double
    L
    R
    z
    w
    m
    abstol
end

arguments (Output)
    Lambda double % diagonal matrix with eigenvalues of \( ( \mathbb{L}_s, \mathbb{L} ) \)
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

% allocate left/right data and base/shifted Loewner matrices
B = zeros(elltheta,n); C = zeros(n,rsigma);
Db = zeros(elltheta,rsigma); Ds = zeros(elltheta,rsigma);

% pre-construct cyclical probing matrices
RR = zeros(n,elltheta); LL = zeros(n,rsigma);

% construct B and C matrices
for i=1:elltheta
    B(i,:) = sum((w ./ (theta(i) - z)) .* reshape(Ql(mod(i-1,Lsize)+1,:,:),n1,N),2);
    RR(:,i) = R(:,mod(i-1,Rsize)+1);
end

for j=1:rsigma
    C(:,j) = sum((w ./ (sigma(j) - z)) .* reshape(Qr(:,mod(j-1,Rsize)+1,:),n2,N),2);
    LL(:,j) = L(:,mod(j-1,Lsize)+1);
end

BB = B*RR; CC = LL'*C;

% construct Lb and Ls matrices
for i=1:elltheta
    for j=1:rsigma
        % ldir = mod(i-1,Lsize)+1; rdir = mod(j-1,Rsize)+1;
        % bb = B(i,:)*R(:,rdir); cc = L(:,ldir)'*C(:,j);
        Db(i,j) = (BB(i,j) - CC(i,j))/(theta(i)-sigma(j));
        Ds(i,j) = (theta(i)*BB(i,j) - sigma(j)*CC(i,j))/(theta(i)-sigma(j));
    end
end

[Lambda,V,W,X,Sigma,Y] = Numerics.realize(m,Db,Ds,B,C,abstol);

end