%% acoustic_wave_1d from the NLEVP collection in the CIMTOOL GUI
%
% Companion to docs/examples/acoustic_wave_1d.md.
% Needs the NLEVP collection on the MATLAB path.

rng(0);   % the probing directions
% --8<-- [start:setup]
N = 506; Xi = 1.0001;
n = Visual.OperatorData([], 'acoustic_wave_1d', sprintf("%f,%f", N, Xi));
c = Visual.Contour.Circle(0.8i, 10, 512);
cim = Visual.CIM(n, c);
% --8<-- [end:setup]

% --8<-- [start:reference]
% the eigenvalues of the continuous problem
n.refew = atan(1i*Xi)/(2*pi) + (-50:50).'/2;
% --8<-- [end:reference]

cimtool = CIMTOOL(cim);
%% Probing directions and the realization order
% --8<-- [start:parameters]
p = 15; cim.SampleData.ell = p; cim.SampleData.r = p;
cim.RealizationData.AutoRank = true;   % m at the largest gap in the singular values of Db
% --8<-- [end:parameters]
%% Hankel
% --8<-- [start:hankel]
cim.setComputationalMode(Numerics.ComputationalMode.Hankel, Numerics.RealizationSize(0, 4));   % Db is 60 x 60
cim.compute();
fprintf('Hankel: m = %d, max relative residual %.1e\n', cim.ResultData.m, cim.maxrelresidual());
% --8<-- [end:hankel]
%% MPLoewner
% --8<-- [start:mploewner]
cim.setComputationalMode(Numerics.ComputationalMode.MPLoewner, Numerics.RealizationSize(0, 4*p));   % Db is 60 x 60
cim.compute();
fprintf('MPLoewner: m = %d, max relative residual %.1e\n', cim.ResultData.m, cim.maxrelresidual());
% --8<-- [end:mploewner]
