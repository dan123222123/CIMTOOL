%% PEEC neutral-delay eigenvalue problem
%
% A partial element equivalent circuit (PEEC) modelled as a neutral delay
% differential equation
%
%     y'(t) = L y(t) + M y(t-tau) + N y'(t-tau).
%
% Recovers the eigenvalues inside an ellipse at tau = 1, tracks them for 201
% delays in [0.2, 2] (written to peec_tau_sweep.csv for peec_figures.m), and
% bounds ||F||_inf to show stability for every delay.
% See Bellen, Guglielmi & Ruehli, IEEE TCAS-I 46(1):212-216, 1999.

% --8<-- [start:setup]
beta = -7;
L = 100*[beta 1 2; 3 -9 0; 1 2 -6];
M = 100*[1 0 -3; -0.5 -0.5 -1; -0.5 -1.5 0];
N = [-1 5 2; 4 0 3; -2 4 1]/72;
I = eye(3);

T = @(s,tau) s*(I - N*exp(-s*tau)) - L - M*exp(-s*tau);
c = Numerics.Contour.Ellipse(0, 2, 10, 1e4);   % semi-axes 2 and 10, 1e4 quadrature nodes

rng(0);
tau = 1;
op  = Numerics.OperatorData(@(s) T(s,tau));
cim = Numerics.CIM(op, c);
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
cim.RealizationData.K = 500;  cim.SampleData.ell = 3;  cim.SampleData.r = 3;
% m from the largest singular-value gap of the Loewner matrix; 0 for an empty ellipse
cim.RealizationData.AutoRank = true;
% --8<-- [end:setup]

%% The eigenvalues inside the ellipse at tau = 1
% The rightmost pair is -0.7376 +- 3.1329i; -0.7379 +- 9.3987i lies just outside.
ew  = cim.eigs();
mrr = cim.maxrelresidual();

fprintf('tau = %g: recovered %d eigenvalues, max relative residual = %.2e\n', ...
        tau, numel(ew), mrr);
disp(sortrows([real(ew) imag(ew)], 1));

%% The eigenvalues inside the ellipse as the delay grows
% --8<-- [start:sweep]
% Each new op.T is sampled on the same contour, with the same probes and shifts.
taus = linspace(0.2, 2, 201);
ews  = cell(size(taus));  rr = cell(size(taus));
for k = 1:numel(taus)
    op.T = @(s) T(s,taus(k));
    [V, D] = cim.eigs();  z = diag(D);
    in = c.inside(z);
    ews{k} = z(in);
    rr{k}  = Numerics.relres(op.T, z(in), V(:,in), op.sample_mode);
end
% --8<-- [end:sweep]
% An eigenvalue is trusted when its relative residual is below 1e-8.
counts = cellfun(@numel, ews);
zall = vertcat(ews{:});  rall = vertcat(rr{:});  trusted = rall < 1e-8;
fprintf('tau = %.1f..%.1f: %d to %d eigenvalues inside, max Re %.4f\n', ...
    taus(1), taus(end), min(counts), max(counts), max(real(zall)));
fprintf('%d trusted (max relative residual %.1e), %d untrusted (relative residual >= 1e-8)\n', ...
    nnz(trusted), max(rall(trusted)), nnz(~trusted));

% A NaN row stands for a delay with nothing inside the ellipse.
e = ews;  e(counts == 0) = {NaN};  r = rr;  r(counts == 0) = {NaN};
tk = repelem(taus, cellfun(@numel, e));  zk = vertcat(e{:});
writetable(table(tk(:), real(zk), imag(zk), vertcat(r{:}), 'VariableNames', {'tau', 're', 'im', 'relres'}), ...
    fullfile(fileparts(mfilename('fullpath')), 'peec_tau_sweep.csv'));

%% Stability for every delay: small-gain bound via the H-infinity norm
% --8<-- [start:hinf]
% T(s) = (sI - L)(I - e^{-s tau} F(s)) with F(s) = N + (sI - L)^{-1}(M + L N).
% L is stable, so ||F||_inf < 1 makes T(s) nonsingular on Re s >= 0 for all tau.
if ~isempty(ver('control')) && license('test', 'Control_Toolbox')
    F = ss(L, M + L*N, eye(3), N);
    fprintf('eig(L) = %s\n', mat2str(eig(L).', 5));
    fprintf('||F||_inf = %.4f\n', hinfnorm(F));
else
    fprintf('Control System Toolbox not available: skipping the H-infinity check.\n');
end
% --8<-- [end:hinf]
