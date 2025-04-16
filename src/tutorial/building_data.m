%% Setup Sigma1 and Sigma2
n = 6; A = diag(-n:-1);
B1 = (1:n)'; C1 = 1:n;
B2 = ones(n,2); C2 = ones(n,2)';
%
H1 = @(z) C1*((z*eye(size(A)) - A) \ B1);
H2 = @(z) C2*((z*eye(size(A)) - A) \ B2);
%% Exact Data, SISO Case
K = n; % half of the number of moments to use in data matrix construction
%% ERA
sigma = Inf; % interpolation point
% construct first 2*K unprobed Markov Parameters
M = Numerics.sploewner.build_exact_moments(sigma,A,B1,C1,2*K);
% build base and shifted data matrices
[Db,Ds] = Numerics.sploewner.build_sploewner(sigma,M,M,M,K);
% check eigenvalues of (regular) pencil (Ds,Db) vs eigenvalues of A
norm(eig(Ds,Db)-diag(A))
%% SPLoewner
% use a finite shift/generalized moments
sigma = 1+1i;
M = Numerics.sploewner.build_exact_moments(sigma,A,B1,C1,2*K);
% build base and shifted data matrices
[Db,Ds] = Numerics.sploewner.build_sploewner(sigma,M,M,M,K);
% check eigenvalues of (regular) pencil (Ds,Db) vs eigenvalues of A
norm(eig(Ds,Db)-diag(A))
%% MPLoewner
theta = 1i*(2:(n+1)); sigma = -1i*(2:(n+1));

% with defaults parameters, both methods produce the same data for the case
% of SISO systems
[~,BB,~,CC] = Numerics.mploewner.build_exact_data(H1,theta,sigma);
% [~,BB,~,CC] = Numerics.mploewner.build_exact_data_siso(H1,theta,sigma);

[Db,Ds] = Numerics.mploewner.build_loewner(BB,CC,theta,sigma);
% without realification, Loewner matrices are generally complex
% (and recovered eigenvalues are not in order)
norm(sort(eig(Ds,Db),"descend")-diag(A))

%% Quadrature Data, MIMO Case
import Visual.*; % allows us to skip subsequent "Visual."s

% say we take an ellipse about our spectrum
% to do this, we specify the center, horizontal/vertical semiradii, and the
% number of quadrature nodes for our contour.
c = Contour.Ellipse(-(n+1)/2,n/2,n/4,8);
% specify our operator of interest
o = OperatorData(H2);
% along with its poles and sampling mode
o.refew = diag(A); o.sample_mode = "Direct";

% with the operator and sampling data set, we can initialize our sampling
% data structure, and assign a plotting axis associated to the operator
% reference poles and contour.
s = SampleData(o,c); s.ax = gca;

% when sampling quadrature, we can sketch to reduce the size of our data
s.ell = 1; s.r = 1; % sketch evaluations of our operator to the SISO case
s.compute(); % compute left/right/two-sided quadrature evaluations, note that this can be done in parallel

%% ERA with Quadrature Data
sigma = Inf; % interpolation point
z = c.z; w = c.w; % quadrature nodes and weights
Ql = s.Ql; Qr = s.Qr; Qlr = s.Qlr; % extract the probed quadrature evaluations
[Ml,Mr,Mlr] = Numerics.sploewner.build_quadrature_moments(sigma,z,w,Ql,Qr,Qlr,K);
[Db,Ds] = Numerics.sploewner.build_sploewner(sigma,Ml,Mr,Mlr,K);
ce = eig(Ds,Db); hold on; cep = scatter(real(ce),imag(ce),"red","filled"); hold off;
% not a great recovery of eigenvalues...

%% Refining Quadrature Data
delete(cep);
s.refineQuadrature(); % doubles the number of quadrature nodes, reusing old quadrature data

sigma = Inf; % interpolation point
z = c.z; w = c.w; % quadrature nodes and weights
Ql = s.Ql; Qr = s.Qr; Qlr = s.Qlr; % extract the probed quadrature evaluations
[Ml,Mr,Mlr] = Numerics.sploewner.build_quadrature_moments(sigma,z,w,Ql,Qr,Qlr,K);
[Db,Ds] = Numerics.sploewner.build_sploewner(sigma,Ml,Mr,Mlr,K);
ce = eig(Ds,Db); hold on; cep = scatter(real(ce),imag(ce),"blue","filled"); hold off;
% looking better!