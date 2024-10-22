n = 2; N = 128; contour = Contour.Circle(0,n,N);
A = randn(n); [C,A,B] = eig(A);
H = @(z) C*((z*eye(n) - A) \ B');
T = @(z) inv(H(z));

[~,~,Qlr] = Numerics.samplequadrature(T,eye(size(A)),eye(size(A)),contour.z);
[Db,Ds] = Numerics.quadrature_sploewner_data(Qlr,Inf,contour.z,contour.w,1);
%eig(Ds,Db)