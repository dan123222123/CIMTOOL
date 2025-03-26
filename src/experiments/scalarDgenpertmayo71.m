% we set nu = rho = 1 and construct a situation as in theorem 4.1 in
% mayo2007

nu = 20; rho = nu;

%% original system and tf
n = nu; m = 1; p = 1;

A = randn(n,n);
B = randn(n,m);
C = randn(p,n);

% D = zeros(p,m);
% epsilon = 10^-2; D = randn(p,m); D = epsilon*(D / norm(D));

H = @(s) C*inv(s*eye(size(A))-A)*B;

%% interpolation points
% irka, say (for theta)
theta = -1*eig(A); sigma = randn(1,"like",1i)*theta;
R = randn(m,rho); L = randn(nu,p); % L dimensions are switch cmp to brennen

%% build data matrices
[LL,LLs,B,C] = Numerics.build_mploewner_data(H,theta,sigma,transpose(L),R);
assert(rank(LL) == nu);

%% delta-parametrized interpolating TF
Htilde = @(s,delta) (C - delta*R)*inv(LLs - delta*L*R - s*LL)*(B - delta*L) + delta;
delta = 10^-2; Htilde(theta(1),0)

Aeigs = eig(A);
Atildeeigs = eig(LLs - delta*L*R, LL);

scatter(real(Aeigs),imag(Aeigs),"blue");
% scatter(real(theta),imag(theta),"blue")
hold on;
scatter(real(Atildeeigs),imag(Atildeeigs),"red");
% scatter(real(sigma),imag(sigma),"red")

s = tf("s");
pHtf = pole(H(s)); pHtildetf = pole(Htilde(s,delta));

% scatter(real(pHtf),imag(pHtf),"magenta");
% scatter(real(pHtildetf),imag(pHtildetf),"green");
hold off;

%% check interpolation
% norm(Htilde(lambda_1)*r_1 - w_1)
% norm(ell_1*Htilde(mu_1) - v_1)

%% check eig
% norm(eig(A) - eig(Atilde))