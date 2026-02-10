%% Test poresz utility function
% Verifies that pole-residue form matches matrix evaluation

clear; close all;
addpath(genpath('../src'));

%% Test 1: Basic evaluation (0-th derivative)
fprintf('Test 1: Basic pole-residue evaluation\n');

% Create test system
Lambda = [1i; -1i; 2+1i];
V = randn(2, 3) + 1i*randn(2, 3);  % Output residue directions (p x n)
W = randn(3, 2) + 1i*randn(3, 2);  % Input residue directions (n x m)
z = 0.5 + 2i;

% Matrix form: H(z) = V * (z*I - Lambda)^(-1) * W
H_matrix = V * ((z*eye(3) - diag(Lambda)) \ W);

% Poresz form
H_poresz = Numerics.poresz(z, Lambda, W, V, 0);

error = norm(H_matrix - H_poresz, 'fro');
fprintf('  Error (0-th derivative): %.2e\n', error);
assert(error < 1e-10, 'Pole-residue evaluation does not match matrix form');

%% Test 2: First derivative
fprintf('\nTest 2: First derivative\n');

% Numerical derivative (finite difference)
delta = 1e-8;
H_plus = V * (((z+delta)*eye(3) - diag(Lambda)) \ W);
H_minus = V * (((z-delta)*eye(3) - diag(Lambda)) \ W);
H_deriv_numerical = (H_plus - H_minus) / (2*delta);

% Poresz derivative
H_deriv_poresz = Numerics.poresz(z, Lambda, W, V, 1);

error = norm(H_deriv_numerical - H_deriv_poresz, 'fro');
fprintf('  Error (1st derivative): %.2e\n', error);
assert(error < 1e-6, 'First derivative does not match numerical derivative');

%% Test 3: SISO system
fprintf('\nTest 3: SISO system\n');

Lambda_siso = [-1; -2; -3];
V_siso = [1; 2; 3]';
W_siso = [1; 1; 1];
z_siso = 0.5;

H_matrix_siso = V_siso * ((z_siso*eye(3) - diag(Lambda_siso)) \ W_siso);
H_poresz_siso = Numerics.poresz(z_siso, Lambda_siso, W_siso, V_siso, 0);

error = abs(H_matrix_siso - H_poresz_siso);
fprintf('  Error (SISO): %.2e\n', error);
assert(error < 1e-10, 'SISO system does not match');

fprintf('\nAll poresz tests passed!\n');
