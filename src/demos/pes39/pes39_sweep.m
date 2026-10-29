%% Bank eigenvalues as one common delay on all ten loops grows
%
% The base bank (pes39_bank.m) is evaluated on 201 common delays in [0, 150] ms,
% and at the common-delay margin, the MPLoewner, ell = 5 row of
% common_margin.csv (pes39_common_margin.m). Writes bank_sweep.csv (every
% eigenvalue at every delay, with its relative residual and whether the bank
% trusts it) and bank_margin.csv (the same at the margin); pes39_figures.m
% plots them.

here = fileparts(mfilename('fullpath'));
[~, ~, ~, Tf] = pes39_model();

t = tic;
% --8<-- [start:sweep]
bank = pes39_bank(Tf);  one = ones(10,1);
cols = {'tau_ms', 're', 'im', 'res', 'trusted'};
tau = linspace(0, 0.15, 201);  sweep = cell(numel(tau), 1);
for j = 1:numel(tau)
    [ew, res, trusted] = bank(tau(j)*one);
    sweep{j} = table(repmat(1e3*tau(j), numel(ew), 1), real(ew), imag(ew), res, trusted, 'VariableNames', cols);
end
% --8<-- [end:sweep]
fprintf('sweep of %d delays: %.0f s\n', numel(tau), toc(t));
writetable(vertcat(sweep{:}), fullfile(here, 'bank_sweep.csv'));

C = readtable(fullfile(here, 'common_margin.csv'), 'TextType', 'string');
tc = 1e-3*C.margin_ms(C.mode == "MPLoewner" & C.ell == 5);
[ew, res, trusted] = bank(tc*one);
writetable(table(repmat(1e3*tc, numel(ew), 1), real(ew), imag(ew), res, trusted, 'VariableNames', cols), ...
    fullfile(here, 'bank_margin.csv'));
fprintf('common-delay margin %.2f ms\n', 1e3*tc);
