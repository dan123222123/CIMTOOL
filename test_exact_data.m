%% construct system of interest
n = 30;
A = randn(n);
[C,A,B] = eig(A);
H = @(z) (C*inv(z*eye(n) - A))*B';
%T = @(z) inv(H(z));
T = @(z) z*eye(n) - A;
N = 128; contour = Contour.Circle(0,10,N);
[theta,sigma] = Numerics.interlevedshifts(contour.z,2*n);
L = Numerics.SampleData.sampleMatrix(n,n);
R = Numerics.SampleData.sampleMatrix(n,n);
%% exact MPLoewner realization using the exact transfer function
ell = 5; r = ell;
Lt = L(:,1:ell); Rt = R(:,1:r);
[Lbe,Lse,Be,Ce] = Numerics.build_exact_MPLoewner_data(H,theta,sigma,Lt,Rt);
Lbswe = svd(Lbe); Lsswe = svd(Lse);
[Xe,Sigmae,Ye] = svd(Lbe,"matrix");
Xe=Xe(:,1:n); Sigmae=Sigmae(1:n,1:n); Ye=Ye(:,1:n);
[Lambdae,Ve] = Numerics.realize(Xe,Sigmae,Ye,Lse,Ce);
%maxrelresidual(T,Lambdae,Ve)
%% Make Axes
f1 = figure(1);
clf(f1);
ax1 = axes(f1,DataAspectRatioMode="manual");
title(ax1,"Complex Plane")

f2 = figure(2);
clf(f2);
ax2 = axes(f2,'yscale','log');
cla(ax2);
title(ax2,"Db/Ds Singular Values")
legend(ax2);

f3 = figure(3);
clf(f3);
ax3 = axes(f3,'yscale','log');
cla(ax3);
title(ax3,"2-norm Eigenvalue Matching Distance")
xlabel(ax3,"N")
merral = animatedline(ax3);
%%
evp = Numerics.NLEVPData(T);
c = Numerics.CIM(evp,contour,ax1,ax2);
c.SampleData.Contour.plot_quadrature = true;
c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
c.SampleData.L = Lt;
c.SampleData.R = Rt;
c.RealizationData.K = 55;
c.RealizationData.m = 30;
%c.auto = true;
c.SampleData.NLEVP.refew = diag(A);
semilogy(ax2,1:length(Lbswe),Lbswe,'DisplayName','refLbsw')
semilogy(ax2,1:length(Lsswe),Lsswe,'DisplayName','refLssw')
c.compute();
%%
clearpoints(merral);

plength=0.5; y = 10:3:150; steps = length(y);
for i=1:length(y)
    title(ax1,sprintf("N = %d",y(i)));
    c.SampleData.Contour.N = y(i);
    try
        c.compute();
    catch E
        warning("issue at N = %d",y(i));
        rethrow(E);
    end
    pause(plength);
    crefew = c.SampleData.NLEVP.refew;
    cew = c.ResultData.ew;
    merr = maxeigmderror(crefew,cew);
    addpoints(merral,y(i),merr);
end