n = 5; m = n;
[Epsilon,sv] = allpass_error_tf(n,m);
T = @(s) inv(Epsilon(s)*Epsilon(s)');
N = 128; contour = Contour.Circle(0,sv*1.1,N);
K = n; [theta,sigma] = Numerics.interlevedshifts(contour.z,K);
L = Numerics.SampleData.sampleMatrix(n,K);
R = Numerics.SampleData.sampleMatrix(n,K);
L = eye(K); R = L;
%% exact MPLoewner realization using the exact transfer function
ell = K; r = ell;
Lt = L(:,1:ell); Rt = R(:,1:r);
[Lbe,Lse,Be,Ce] = Numerics.build_mploewner_data(Epsilon,theta,sigma,Lt,Rt);
Lbswe = svd(Lbe); Lsswe = svd(Lse);
[Xe,Sigmae,Ye] = svd(Lbe,"matrix");
Xe=Xe(:,1:n); Sigmae=Sigmae(1:n,1:n); Ye=Ye(:,1:n);
[Lambdae,Ve] = Numerics.realize(Xe,Sigmae,Ye,Lse,Ce);
display(Sigmae)