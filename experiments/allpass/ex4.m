ddir = "/home/dfolescu/version_control/git/math/code/packages/CIMTOOL/experiments/allpass/ex4Data/";
mkdir(ddir);
%% Make all-pass error system
n = 8;
[A,B,C,D] = sallpass(n);
Etf = @(s) C * ((s * eye(n) - A) \ B);
errpoles = sort(eig(A));
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
contour = Numerics.Contour.Circle(ev,mdist/2,64);
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
CIM.RealizationData.m = 1;
CIM.RealizationData.K = 1;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
saveData(strcat(ddir,"ex1Hankel"),CIM);
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
saveData(strcat(ddir,"ex1MPLoewner"),CIM);
%%
CIM.SampleData.Contour.rho = 0.9412576656659196;
CIM.RealizationData.m = 3;
CIM.RealizationData.K = 3;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
saveData(strcat(ddir,"ex2Hankel"),CIM);
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
saveData(strcat(ddir,"ex2MPLoewner"),CIM);
%%
CIM.SampleData.Contour.gamma = -0.11319-0.25416i;
CIM.SampleData.Contour.rho = 1.4506436235020579;
CIM.RealizationData.m = 5;
CIM.RealizationData.K = 5;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
saveData(strcat(ddir,"ex3Hankel"),CIM);
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
saveData(strcat(ddir,"ex3MPLoewner"),CIM);