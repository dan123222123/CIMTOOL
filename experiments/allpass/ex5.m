ddir = "/home/dfolescu/version_control/git/math/code/packages/CIMTOOL/experiments/allpass/ex5Data/";
mkdir(ddir);
%% Make all-pass error system
n = 4;
lr = linspace(-n,-1,n);
refeig = lr;
A = diag(refeig); B = rand(n,n); C = B'; D = 0;
rsv = 1; [Ess,Etf] = allpass_error_ssin_sstfout(A,B,C,D,rsv);
errpoles = sort(eig(Ess.A));
%% Pick an eigenvalue of Etf/region of the complex plane
ev = errpoles(1);
mdist = Inf;
for i=2:length(errpoles)
    if norm(ev-errpoles(i)) < mdist
        mdist = norm(ev-errpoles(i));
    end
end
%% Make CIM/start GUI
T = @(s) inv(Etf(s));
nlevp = Numerics.NLEVPData(T);
contour = Numerics.Contour.Circle(ev,mdist/2,128);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.NLEVP.refew = errpoles;
c = CIMTOOL(CIM);
%% helper to save results
function saveData(fname,CIM)
    errpoles = CIM.SampleData.NLEVP.refew;
    CIM.compute();
    [Db,Ds] = CIM.getData();
    rew = errpoles(CIM.SampleData.Contour.inside(errpoles));
    save(fname,"Db","Ds","rew");
end
%%
CIM.RealizationData.m = length(errpoles(CIM.SampleData.Contour.inside(errpoles)));
CIM.RealizationData.K = 1;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
saveData(strcat(ddir,"ex1Hankel"),CIM);
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.RealizationData.K = 4;
saveData(strcat(ddir,"ex1MPLoewner"),CIM);
%%
CIM.SampleData.Contour.rho = 1.5100041833175553;
CIM.RealizationData.m = length(errpoles(CIM.SampleData.Contour.inside(errpoles)));
CIM.RealizationData.K = 1;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
saveData(strcat(ddir,"ex2Hankel"),CIM);
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.RealizationData.K = 4;
saveData(strcat(ddir,"ex2MPLoewner"),CIM);
%%
CIM.SampleData.Contour.gamma = 0;
CIM.SampleData.Contour.rho = 2.409524284426337;
CIM.RealizationData.m = length(errpoles(CIM.SampleData.Contour.inside(errpoles)));
CIM.RealizationData.K = 1;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
saveData(strcat(ddir,"ex3Hankel"),CIM);
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.RealizationData.K = 4;
saveData(strcat(ddir,"ex3MPLoewner"),CIM);