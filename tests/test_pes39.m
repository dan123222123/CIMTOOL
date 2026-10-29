%% Test the delayed PES 39-bus benchmark (published data, ten delayed loops)
% Checks the model against the published spectrum, and one disk of the base bank
% against Newton refinement past the common-delay margin. The first run
% downloads the published files (see pes39_model.m).

clear; close all;
addpath(genpath('../src'));
[A0, B, E, Tf] = pes39_model();  n = size(A0,1);
osc = @(e) e(isfinite(e) & imag(e) > 1 & abs(e) < 1e3);

%% Test 1: published spectrum without delay; unstable with the loops removed
fprintf('Test 1: model\n');
e = osc(eig(A0 + B*E'));  [~, i] = max(real(e));
assert(abs(e(i) - (-0.4985 + 3.6822i)) < 1e-4, 'rightmost without delay is %+.4f%+.4fi', real(e(i)), imag(e(i)));
assert(max(real(osc(eig(A0)))) > 0.19, 'loops removed should leave an unstable oscillation');
fprintf('  rightmost %+.4f%+.4fi; no PSS %+.4f\n', real(e(i)), imag(e(i)), max(real(osc(eig(A0)))));

%% Test 2: one disk at the unstable eigenvalue vs Newton refinement
fprintf('Test 2: CIM past the margin, common delay 100 ms\n');
tau = 0.1*ones(10,1);  T = Tf(tau);
bank = pes39_bank(Tf, 'Centers', 10);
[ew, ~, trusted] = bank(tau);  ew = ew(trusted);
[~, i] = max(real(ew));  zc = ew(i);
dT = @(z) eye(n) + B*diag(tau.*exp(-z*tau))*E';
ws = warning('off', 'MATLAB:nearlySingularMatrix');   % T(z) is singular at the converged eigenvalue
zn = zc;  for it = 1:10, dz = 1/trace(T(zn)\dT(zn)); zn = zn - dz; if abs(dz) < 1e-13, break; end, end
warning(ws);
assert(abs(zc - zn) < 1e-9, 'crossing mismatch: Newton %.1e', abs(zc - zn));
assert(abs(zc - (0.0580 + 10.2987i)) < 1e-3, 'unexpected eigenvalue %+.5f%+.5fi', real(zc), imag(zc));
fprintf('  %+.6f%+.6fi; Newton %.1e\n', real(zc), imag(zc), abs(zc - zn));
fprintf('test_pes39: all tests passed\n');
