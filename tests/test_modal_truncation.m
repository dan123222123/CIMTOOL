%% Test ModalTruncation class
% Verifies modal truncation workflow: H = H_region + H_residual

clear; close all;
addpath(genpath('../src'));

%% Test 1: Synthetic system with known eigenvalues
fprintf('Test 1: Modal truncation with circular segment\n');

% Create known system with unstable (RHP) and stable (LHP) poles
ew_unstable = [0.1+0.5i; 0.1-0.5i];  % Unstable (right half-plane)
ew_stable = [-0.5+0.3i; -0.5-0.3i; -1+0.2i; -1-0.2i];  % Stable (left half-plane)
ew_full = [ew_unstable; ew_stable];

% Create SISO system
V = randn(1, length(ew_full));
W = randn(length(ew_full), 1);
H_full = @(z) Numerics.poresz(z, ew_full, W, V);
H_stable = @(z) Numerics.poresz(z, ew_stable, W, V);
H_unstable = @(z) Numerics.poresz(z, ew_unstable, W, V);

% Use circular segment to isolate unstable region (RHP)
contour = Numerics.Contour.CircularSegment(...
    0,...           % gamma: center near unstable poles
    0.8,...           % rho: radius to enclose unstable poles
    [-pi/2, pi/2],... % theta: cover right half-plane
    [32; 64]...       % N: quadrature points [arc; chord]
);

% Configure realization
rd = Numerics.RealizationData();
rd.RealizationSize = Numerics.RealizationSize(2, 2);  % Expect 2 unstable poles
rd.ComputationalMode = Numerics.ComputationalMode.Hankel;

% Create and compute modal truncation
mt = Numerics.ModalTruncation(H_full, contour, rd);
mt.compute();

% Extract subsystems
H_region = mt.getRegionTransferFunction();
% H_residual = mt.getResidualTransferFunction();
ew_computed = mt.getRegionEigenvalues();

% visual
scatter(real(contour.z),imag(contour.z)); hold on;
scatter(real(ew_stable),imag(ew_stable))
scatter(real(ew_unstable),imag(ew_unstable))
scatter(real(ew_computed),imag(ew_computed))
hold off

fprintf('  True unstable eigenvalues: %d\n', length(ew_unstable));
fprintf('  Computed eigenvalues: %d\n', length(ew_computed));
fprintf('  Computed eigenvalues (real parts): [%.3f, %.3f]\n', real(ew_computed));

Herr = @(z) H_region(z) - H_unstable(z);

fprintf('  Maximum decomposition error: %.2e\n', Numerics.linfnumnorm_siso(Herr));
assert(Numerics.linfnumnorm_siso(Herr) < 1e-6, 'Decomposition error too large');

% Verify computed eigenvalues are in RHP
assert(all(real(ew_computed) > -0.1), 'Some computed eigenvalues not in RHP region');

%% Test 2: Different contour types
fprintf('\nTest 2: Modal truncation with ellipse\n');

% Use ellipse to isolate a different region
contour = Numerics.Contour.Ellipse(0, 0.25, 1, 128);

mt = Numerics.ModalTruncation(H_full, contour, rd);
mt.compute();

H_region = mt.getRegionTransferFunction();
ew_computed = mt.getRegionEigenvalues();
% H_residual = mt.getResidualTransferFunction();

Herr = @(z) H_region(z) - H_unstable(z);

% % visual
% scatter(real(contour.z),imag(contour.z)); hold on;
% scatter(real(ew_stable),imag(ew_stable))
% scatter(real(ew_unstable),imag(ew_unstable))
% scatter(real(ew_computed),imag(ew_computed))
% hold off

fprintf('  Maximum decomposition error (ellipse): %.2e\n', Numerics.linfnumnorm_siso(Herr));
assert(Numerics.linfnumnorm_siso(Herr) < 1e-6, 'Decomposition error too large with ellipse');

% %% Test 3: Verify eigenvalues inside contour
% fprintf('\nTest 3: Verify eigenvalues inside contour\n');
% 
% ew_computed_ellipse = mt.getRegionEigenvalues();
% inside_count = sum(contour.inside(ew_computed_ellipse));
% 
% fprintf('  Computed eigenvalues: %d\n', length(ew_computed_ellipse));
% fprintf('  Eigenvalues inside ellipse: %d\n', inside_count);
% 
% % All computed eigenvalues should be inside the contour
% assert(inside_count == length(ew_computed_ellipse), 'Not all eigenvalues inside contour');
% 
% %% Test 4: Changing contour after construction
% fprintf('\nTest 4: Changing contour dynamically\n');
% 
% % Create with circle, then change to circular segment
% mt3 = Numerics.ModalTruncation(H_full);
% mt3.setContour(contour);
% mt3.compute();
% 
% H_region3 = mt3.getRegionTransferFunction();
% H_residual3 = mt3.getResidualTransferFunction();
% 
% % Verify decomposition
% max_error3 = 0;
% for z_test = test_points
%     error = abs(H_full(z_test) - (H_region3(z_test) + H_residual3(z_test)));
%     max_error3 = max(max_error3, error);
% end
% 
% fprintf('  Maximum decomposition error (changed contour): %.2e\n', max_error3);
% assert(max_error3 < 1e-6, 'Decomposition error too large after changing contour');

fprintf('\nAll modal truncation tests passed!\n');

% should make the tests deterministic & test reconstruction of the stable
% part in the appropriate norm!
