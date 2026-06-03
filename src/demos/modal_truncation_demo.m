%% Modal Truncation Demo
% Demonstrates isolating unstable subsystem using circular segment contour

clear; close all;

%% Create synthetic system with mixed stable/unstable poles
fprintf('=== Modal Truncation Demo ===\n\n');
fprintf('Creating synthetic system with mixed eigenvalues...\n');

% Unstable poles (right half-plane)
ew_unstable = [0.2+0.5i, 0.2-0.5i];

% Stable poles (left half-plane)
ew_stable = [-0.5+1i, -0.5-1i, -1+0.2i, -1-0.2i];

% Combined eigenvalues
ew_all = [ew_unstable, ew_stable];

% Create SISO transfer function
rng(42);  % For reproducibility
V = randn(1, length(ew_all));
W = randn(length(ew_all), 1);
H = @(z) Numerics.poresz(z, ew_all, W, V);

fprintf('  Unstable eigenvalues: %d\n', length(ew_unstable));
fprintf('  Stable eigenvalues: %d\n', length(ew_stable));
fprintf('  Total eigenvalues: %d\n', length(ew_all));

%% Setup modal truncation to isolate unstable region
fprintf('\nConfiguring modal truncation with circular segment...\n');

% Choose circular segment covering right half-plane
contour = Numerics.Contour.CircularSegment(...
    0,...           % gamma: center at mean of unstable poles
    0.7,...           % rho: radius to enclose unstable poles
    [-pi/2, pi/2],... % theta: cover right half-plane
    [32; 32]...       % N: quadrature points [arc; chord]
);

fprintf('  Contour: Circular segment\n');
fprintf('  Center: %.2f + %.2fi\n', real(contour.gamma), imag(contour.gamma));
fprintf('  Radius: %.2f\n', contour.rho);
fprintf('  Angular range: [%.2f, %.2f] rad\n', contour.theta(1), contour.theta(2));

% Configure realization
rd = Numerics.RealizationData();
rd.RealizationSize = Numerics.RealizationSize(2, 5, 5);  % Expect 2 unstable poles
rd.ComputationalMode = Numerics.ComputationalMode.Hankel;

%% Compute modal truncation
fprintf('\nComputing modal truncation...\n');

mt = Numerics.ModalTruncation(H, contour, rd);
mt.compute();

fprintf('  Computation complete!\n');

%% Extract subsystems
H_unstable = mt.getRegionTransferFunction();
H_stable = mt.getResidualTransferFunction();
ew_computed = mt.getRegionEigenvalues();

fprintf('\nResults:\n');
fprintf('  True unstable eigenvalues:\n');
for i = 1:length(ew_unstable)
    fprintf('    %.3f %+.3fi\n', real(ew_unstable(i)), imag(ew_unstable(i)));
end
fprintf('  Computed eigenvalues:\n');
for i = 1:length(ew_computed)
    fprintf('    %.3f %+.3fi\n', real(ew_computed(i)), imag(ew_computed(i)));
end

%% Verify decomposition
fprintf('\nVerifying decomposition H = H_unstable + H_stable...\n');

test_points = [1i, 0.5, -1, 0.1+0.2i, -0.5+0.5i];
errors = zeros(size(test_points));

for i = 1:length(test_points)
    z = test_points(i);
    errors(i) = abs(H(z) - (H_unstable(z) + H_stable(z)));
end

fprintf('  Maximum decomposition error: %.2e\n', max(errors));
fprintf('  Average decomposition error: %.2e\n', mean(errors));

%% Plot eigenvalues and contour
figure('Position', [100, 100, 800, 600]);

% Plot true eigenvalues
hold on;
scatter(real(ew_unstable), imag(ew_unstable), 150, 'r', 'filled', ...
    'DisplayName', 'True Unstable', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
scatter(real(ew_stable), imag(ew_stable), 150, 'b', 'filled', ...
    'DisplayName', 'True Stable', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);

% Plot computed eigenvalues
scatter(real(ew_computed), imag(ew_computed), 100, 'k', 'x', ...
    'LineWidth', 3, 'DisplayName', 'Computed (Region)');

% Plot contour
plot(real(contour.z), imag(contour.z), 'k-', 'LineWidth', 2, ...
    'DisplayName', 'Contour');

% Mark contour center
plot(real(contour.gamma), imag(contour.gamma), 'ko', ...
    'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, ...
    'DisplayName', 'Contour Center');

% Add imaginary axis
plot([0 0], ylim, 'k--', 'LineWidth', 0.5, 'HandleVisibility', 'off');

grid on; axis equal;
xlabel('Re(\lambda)'); ylabel('Im(\lambda)');
title('Modal Truncation: Isolating Unstable Subsystem');
legend('Location', 'best', 'FontSize', 10);
set(gca, 'FontSize', 12);

%% Plot frequency responses
figure('Position', [100, 100, 1200, 400]);

% Frequency range
omega = logspace(-2, 2, 500);
s = 1i*omega;

% Evaluate transfer functions
H_vals = zeros(size(s));
H_unstable_vals = zeros(size(s));
H_stable_vals = zeros(size(s));

for i = 1:length(s)
    H_vals(i) = H(s(i));
    H_unstable_vals(i) = H_unstable(s(i));
    H_stable_vals(i) = H_stable(s(i));
end

% Magnitude plot
subplot(1, 2, 1);
loglog(omega, abs(H_vals), 'k-', 'LineWidth', 2, 'DisplayName', 'Full H');
hold on;
loglog(omega, abs(H_unstable_vals), 'r--', 'LineWidth', 2, 'DisplayName', 'H_{unstable}');
loglog(omega, abs(H_stable_vals), 'b--', 'LineWidth', 2, 'DisplayName', 'H_{stable}');
grid on;
xlabel('Frequency \omega (rad/s)');
ylabel('Magnitude |H(i\omega)|');
title('Frequency Response (Magnitude)');
legend('Location', 'best');
set(gca, 'FontSize', 10);

% Phase plot
subplot(1, 2, 2);
semilogx(omega, angle(H_vals)*180/pi, 'k-', 'LineWidth', 2, 'DisplayName', 'Full H');
hold on;
semilogx(omega, angle(H_unstable_vals)*180/pi, 'r--', 'LineWidth', 2, 'DisplayName', 'H_{unstable}');
semilogx(omega, angle(H_stable_vals)*180/pi, 'b--', 'LineWidth', 2, 'DisplayName', 'H_{stable}');
grid on;
xlabel('Frequency \omega (rad/s)');
ylabel('Phase (degrees)');
title('Frequency Response (Phase)');
legend('Location', 'best');
set(gca, 'FontSize', 10);

%% Summary
fprintf('\n=== Demo Complete ===\n');
fprintf('Modal truncation successfully isolated unstable subsystem.\n');
fprintf('The stable subsystem H_stable can now be used for further analysis\n');
fprintf('or model order reduction with external tools.\n');
