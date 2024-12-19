%% setup CIM
% problem setup
refew = -10:-1; A = diag(refew); [V,~] = eig(A); T = @(z) (z*eye(10) - diag(refew));
n = length(refew);

% % % change contour parameters % % %
gamma = 0; rho = 2.5;
% gamma = -1; rho = 2.5;
% gamma = -2; rho = 2.5;

% left/right probing matrices
L = Numerics.SampleData.sampleMatrix(n,n); R = Numerics.SampleData.sampleMatrix(n,n);

% set up CIM
nlevp = Numerics.NLEVPData(T); contour = Numerics.Contour.Circle(gamma,rho); CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.Lf = L; CIM.SampleData.Rf = R;

% additional CIM setup
CIM.SampleData.show_progress = false; CIM.SampleData.NLEVP.refew = refew;

% % % % any CIM modifications here % % % %
CIM.RealizationData.ShiftScale = 1.5;
%% repeatable script
% pick out ew/ev within the contour
refewin = refew(CIM.SampleData.Contour.inside(refew)); refevin = V(:,CIM.SampleData.Contour.inside(refew)); 
m = length(refewin); CIM.RealizationData.m = m;

KHankel = 1; KMPLoewner = m; pd = m;
CIM.SampleData.ell = pd; CIM.SampleData.r = pd;

% Exact Hankel
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
Vh = refevin; Ah = diag(refewin); Wh = refevin';
CIM.RealizationData.K = KHankel; % # of Hankel moments
M = Numerics.build_moments(CIM.RealizationData.K,Ah,Wh,Vh,CIM.SampleData.L,CIM.SampleData.R);
[Hb,Hs] = Numerics.build_sploewner_data(CIM.RealizationData.K,M,Inf);
HLambda = Numerics.realize(m,Hb,Hs,NaN);

% Exact MPLoewner
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
H = @(z) refevin*inv(z*eye(m) - diag(refewin))*refevin';
CIM.RealizationData.K = KMPLoewner; % # of interpolants
[Lb,Ls,~,CC] = Numerics.build_mploewner_data(H,CIM.RealizationData.InterpolationData.theta,CIM.RealizationData.InterpolationData.sigma,CIM.SampleData.L,CIM.SampleData.R);
[MPLLambda,MPLV] = Numerics.realize(m,Lb,Ls,CC);

% inexact investigation

% exact/inexact data matrix norm convergence
Df = figure(1); clf(Df); axDNn = axes(Df,"yscale","log"); hold(axDNn,"on");
ylabel('$\Vert D - D^{(N)} \Vert$','Interpreter','latex'); xlabel('N');
HankelNbn = animatedline(axDNn, 'Color','r','DisplayName','Hb'); HankelNsn = animatedline(axDNn,'Color','y','DisplayName','Hs');
MPLoewnerNbn = animatedline(axDNn,'Color','b','DisplayName','Lb'); MPLoewnerNsn = animatedline(axDNn,'Color','g','DisplayName','Ls');
legend(axDNn,'Location','northoutside','Orientation','horizontal');

% worst residual norm
WRf = figure(2); clf(WRf); axWR = axes(WRf,"yscale","log"); hold(axWR,"on");
xlabel('N'); ylabel('$\max_i \frac{ \Vert T(\lambda_i) v_i \Vert_2 }{ \Vert T(\lambda_i) \Vert_F }$','Interpreter','latex');
HankelWR = animatedline(axWR, 'Color','r','DisplayName','Hankel');
MPLoewnerWR = animatedline(axWR,'Color','b','DisplayName','MPLoewner');
legend(axWR,'Location','northoutside','Orientation','horizontal');

for N = 2:150
    CIM.SampleData.Contour.N = N;
    % Hankel
    CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
    CIM.RealizationData.K = KHankel; % # of Hankel moments
    CIM.compute();
    [HbC,HsC] = CIM.getData();
    cHWR = max(Numerics.relres(nlevp.T,CIM.ResultData.ew,CIM.ResultData.ev));
    addpoints(HankelWR,N,cHWR);
    % MPLoewner
    CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
    CIM.RealizationData.K = KMPLoewner; % # of interpolants
    CIM.compute();
    [LbC,LsC] = CIM.getData();
    cMPLWR = max(Numerics.relres(nlevp.T,CIM.ResultData.ew,CIM.ResultData.ev));
    addpoints(MPLoewnerWR,N,cMPLWR);
    %
    addpoints(HankelNbn,N,norm(Hb - HbC));
    addpoints(HankelNsn,N,norm(Hs - HsC));
    addpoints(MPLoewnerNbn,N,norm(Lb - LbC));
    addpoints(MPLoewnerNsn,N,norm(Ls - LsC));
    drawnow;
    if any([cHWR < eps; cMPLWR < eps])
        break;
    end
end