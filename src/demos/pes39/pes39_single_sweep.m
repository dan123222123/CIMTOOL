%% Bank eigenvalues as the delay on the worst single loop grows
%
% The worst loop is the one with the smallest margin in single_margin.csv
% (pes39_single_margin.m). Only that loop is delayed, tau = r*e_k, on the grid
% of pes39_sweep.m and at its margin. Writes single_sweep.csv (every eigenvalue
% at every delay, with its relative residual and whether the bank trusts it)
% and single_bank.csv (the same at the margin); pes39_fig_single_bank.m plots
% them.

here = fileparts(mfilename('fullpath'));
[~, ~, ~, Tf] = pes39_model();
S = readtable(fullfile(here, 'single_margin.csv'), 'TextType', 'string');
[tc, i] = min(1e-3*S.margin_ms);  k = S.delayed_loop(i);
u = zeros(10,1);  u(k) = 1;
bank = pes39_bank(Tf);
cols = {'delayed_loop', 'tau_ms', 're', 'im', 'res', 'trusted'};

tau = linspace(0, 0.15, 201);  sweep = cell(numel(tau), 1);
t = tic;
for j = 1:numel(tau)
    [ew, res, trusted] = bank(tau(j)*u);
    sweep{j} = table(repmat(k, numel(ew), 1), repmat(1e3*tau(j), numel(ew), 1), real(ew), imag(ew), res, trusted, 'VariableNames', cols);
end
fprintf('sweep of %d delays: %.0f s\n', numel(tau), toc(t));
writetable(vertcat(sweep{:}), fullfile(here, 'single_sweep.csv'));

[ew, res, trusted] = bank(tc*u);
writetable(table(repmat(k, numel(ew), 1), repmat(1e3*tc, numel(ew), 1), real(ew), imag(ew), res, trusted, 'VariableNames', cols), ...
    fullfile(here, 'single_bank.csv'));
fprintf('worst single loop %d, margin %.2f ms\n', k, 1e3*tc);
