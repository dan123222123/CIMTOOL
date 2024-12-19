%% problem setup
refew = -10:-1; n = length(refew);
A = diag(refew); [V,~] = eig(A);
T = @(z) (z*eye(10) - diag(refew));

L = Numerics.SampleData.sampleMatrix(n,n); R = Numerics.SampleData.sampleMatrix(n,n);
%% CIM/CIMTOOL
nlevp = Numerics.NLEVPData(T);
gamma = 0; rho = 2.5; contour = Numerics.Contour.Circle(gamma,rho);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = refew;
c = CIMTOOL(CIM); f = c.PlotPanel.MainPlotAxes;
%% MPLoewner N increasing
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
refewin = refew(contour.inside(refew));
refevin = V(:,contour.inside(refew));
m = length(refewin); K = 4*m;

H = @(z) refevin*inv(z*eye(m) - diag(refewin))*refevin';

CIM.RealizationData.m = m; CIM.RealizationData.K = K;


[Lb,Ls,~,CC] = Numerics.build_mploewner_data(H,CIM.RealizationData.InterpolationData.theta,CIM.RealizationData.InterpolationData.sigma,CIM.SampleData.L,CIM.SampleData.R);
[MPLLambda,MPLV] = Numerics.realize(m,Lb,Ls,CC);
if exist('cep','var') == 1; delete(cep); end 
cep = scatter(f,real(MPLLambda),imag(MPLLambda),50,"filled");

hold(f,"on"); axis(f,"manual");
xlim(f,[-3.5,3.5]); ylim(f,[-2.5,2.5]);

Df = figure(2); axDDN = axes(Df,"yscale","log"); cla(axDDN);
hold(axDDN,"on"); DDNb = animatedline(axDDN); DDNs = animatedline(axDDN);

for N = 2:128
    CIM.SampleData.Contour.N = N;
    CIM.compute();
    [LbC,LsC] = CIM.getData();
    addpoints(DDNb,N,norm(Lb - LbC));
    addpoints(DDNs,N,norm(Ls - LsC));
    drawnow;
end
%% Hankel N increasing
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
refewin = refew(contour.inside(refew));
refevin = V(:,contour.inside(refew));

% 1 moment realization
m = length(refewin); K = 2;
Vh = refevin; Ah = diag(refewin); Wh = refevin';
M = Numerics.build_moments(K,Ah,Wh,Vh,L(:,1:m),R(:,1:m));
[Db,Ds] = Numerics.build_sploewner_data(K,M,Inf);
HLambda = Numerics.realize(m,Db,Ds,NaN);

if exist('cep','var') == 1; delete(cep); end 
cep = scatter(f,real(HLambda),imag(HLambda),50,"filled");

hold(f,"on"); axis(f,"manual");
xlim(f,[-3.5,3.5]); ylim(f,[-2.5,2.5]);

Df = figure(3); axDDN = axes(Df,"yscale","log"); cla(axDDN);
hold(axDDN,"on"); DDNb = animatedline(axDDN); DDNs = animatedline(axDDN);

CIM.SampleData.Lf = L(:,1:m); CIM.SampleData.Rf = R(:,1:m);
CIM.SampleData.ell = m; CIM.SampleData.r = m;
CIM.RealizationData.m = m; CIM.RealizationData.K = K;

for N = 2:128
    CIM.SampleData.Contour.N = N;
    CIM.compute();
    [DbC,DsC] = CIM.getData();
    addpoints(DDNb,N,norm(Db - DbC));
    addpoints(DDNs,N,norm(Ds - DsC));
    drawnow;
end