% we set nu = rho = 1 and construct a situation as in theorem 4.1 in
% mayo2007

nu = 1; rho = 1;

n = 1; m = 1; p = 1;

% D = zeros(p,m);
epsilon = 10^-2; D = randn(p,m); D = epsilon*(D / norm(D));

%% original system and tf
A = randn(n,n);
B = randn(n,m);
C = randn(p,n);
H = @(s) C*inv(s*eye(size(A))-A)*B;

%% construct data
% right data
lambda_1    = randn(1,"like",1i);
r_1         = randn(m,rho);
w_1         = H(lambda_1)*r_1;

% left data
mu_1        = randn(1,"like",1i);
ell_1       = randn(nu,p);
v_1         = ell_1*H(mu_1);

LL = (v_1*r_1 - ell_1*w_1)/(mu_1 - lambda_1);
assert(rank(LL) == nu);

%% realization

Atilde = lambda_1 + inv(LL)*(v_1*r_1 - ell_1*D*r_1);
Btilde = inv(LL)*(v_1 - ell_1*D);
Ctilde = -1 * (w_1 - D*r_1);

Htilde = @(s) Ctilde*inv(s*eye(size(Atilde))-Atilde)*Btilde + D;

%% check interpolation
norm(Htilde(lambda_1)*r_1 - w_1)
norm(ell_1*Htilde(mu_1) - v_1)

%% check eig
norm(eig(A) - eig(Atilde))