%% preparation
% error tolerance for subsequent asserts
tol = 10^-6;
% sample nlevp and contour
[coeffs,fun,f] = nlevp('qep3',1i);
n = length(coeffs{1});
e = polyeig(coeffs{:});
e = sort(e);
m=1;
gamma = 0;
rho = 0.5;
centers = [real(gamma) imag(gamma)];
radii = rho;

% make trapezoid rule for N-point quadrature of circle ^
N = 32;
thetak = (2*pi/N)*((1:N)-1/2);
zk = gamma + rho*exp(1i*thetak); 
wk = (rho/N)*exp(1i*thetak);

% generate two-sided samples of nlevp at the zk
L=eye(n); R=eye(n);
[Ql,Qr,Qlr] = samplequadrature(f,L,R,zk);
%% hankel
eh = sploewner(Qlr,Inf,zk,wk,m,1);
assert(norm(sort(eh)-e(1:m))<tol)
%% sploewner at sigma=-1
sigma=-1.5;
el = sploewner(Qlr,sigma,zk,wk,m,1);
assert(norm(sort(el)-e(1:m))<tol)
%% mploewner at theta=[-1.5+2i,-1.5,-1.5-2i], sigma=[1.5+2i,1.5,1.5-2i]
thetamp = [-1.5+2i,-1.5,-1.5-2i]; sigmamp = [1.5+2i,1.5,1.5-2i];
elmp = mploewner(Ql,Qr,thetamp,sigmamp,L,R,zk,wk,m);
assert(norm(sort(elmp)-e(1:m))<tol)
%% plot things to see how we did
scatter(real(e),imag(e),"*");
hold on;
viscircles(centers,radii);
scatter(real(zk),imag(zk),"x");
scatter(real(eh),imag(eh),"o");
scatter(real(sigma),imag(sigma),"square");
scatter(real(el),imag(el),"diamond");
scatter(real(thetamp),imag(thetamp),"pentagram","b");
scatter(real(sigmamp),imag(sigmamp),"hexagram","r");
scatter(real(elmp),imag(elmp),"<");
hold off;
axis equal;