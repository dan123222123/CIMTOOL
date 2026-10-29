%% The tritare in the CIMTOOL GUI
%
% The theta = pi/2 tritare of nlevp_webs, a 12 x 12 trigonometric NEP with ten simple eigenvalues inside |z - 2i| < 1.5 and references to 30 digits.
% tritare_web.m is the full tour.
% Needs nlevp_webs (github.com/jpeterbaker/nlevp_webs) on the MATLAB path.

assert(exist('tritare','file') == 2, ...
    'tritare_simple: nlevp_webs must be on the path (github.com/jpeterbaker/nlevp_webs).');

rng(0);   % the probing directions
[T, ~, ~, ~, ~, ew_ref] = tritare(pi/2);
n = Visual.OperatorData(T);
n.refew = ew_ref;
c = Visual.Contour.Circle(2i, 1.5, 512);
cim = Visual.CIM(n, c);

cimtool = CIMTOOL(cim);
%% Probing directions and the realization order
p = 12; cim.SampleData.ell = p; cim.SampleData.r = p;
cim.RealizationData.AutoRank = true;   % m at the largest gap in the singular values of Db
%% Hankel, K = 4 moments
cim.setComputationalMode(Numerics.ComputationalMode.Hankel, Numerics.RealizationSize(0, 4));
cim.compute();
fprintf('Hankel: m = %d, max relative residual %.1e\n', cim.ResultData.m, cim.maxrelresidual());
%% MPLoewner, K = 64 points
cim.setComputationalMode(Numerics.ComputationalMode.MPLoewner, Numerics.RealizationSize(0, 64));
cim.compute();
fprintf('MPLoewner: m = %d, max relative residual %.1e\n', cim.ResultData.m, cim.maxrelresidual());
%% Matching distance to the 30-digit references
fprintf('matching distance %.1e\n', cim.matchingDistance());
