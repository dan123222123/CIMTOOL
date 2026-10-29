%% Experiment 1: delay margin with one common delay on all ten loops
%
% tau = r*ones(10,1). The margin is the smallest r at which the bank
% (pes39_bank.m) trusts an eigenvalue with positive real part (pes39_margin.m).
% Every computational mode computes it with several probing sizes ell = r. The
% data matrix is about 50 x 50 in each: K = 50 interpolation points for
% MPLoewner, K = ceil(50/ell) moments for Hankel and SPLoewner. Writes common_margin.csv

here = fileparts(mfilename('fullpath'));
[~, ~, ~, Tf] = pes39_model();
modes  = [Numerics.ComputationalMode.Hankel, Numerics.ComputationalMode.SPLoewner, Numerics.ComputationalMode.MPLoewner];
probes = [1 2 5 10 20];

rows = cell(0, 9);
fprintf('%-10s %4s %4s %11s %24s %6s %7s\n', 'mode', 'ell', 'K', 'margin', 'crossing eigenvalue', 'banks', 'time');
for md = modes
    for ell = probes
        K = 50;  if md ~= Numerics.ComputationalMode.MPLoewner, K = ceil(50/ell); end
        t = tic;
        try
            bank = pes39_bank(Tf, 'Mode', md, 'Probes', ell, 'K', K);
            [tc, zc, nb] = pes39_margin(bank, ones(10,1));
            % at a true crossing the rightmost eigenvalue sits on the axis; anything
            % else means the bank missed an eigenvalue and fzero found the jump
            status = "ok";  if abs(real(zc)) > 1e-6, status = "jump"; end
            fprintf('%-10s %4d %4d %8.2f ms   %+10.5f %+10.5fi %6d %5.0f s\n', char(md), ell, K, 1e3*tc, real(zc), imag(zc), nb, toc(t));
        catch err
            [tc, zc, nb] = deal(NaN);  status = string(err.message);
            fprintf('%-10s %4d %4d   failed: %s\n', char(md), ell, K, err.message);
        end
        rows(end+1, :) = {string(char(md)), ell, K, 1e3*tc, real(zc), imag(zc), nb, toc(t), status};
    end
end
writetable(cell2table(rows, 'VariableNames', {'mode', 'ell', 'K', 'margin_ms', 'crossing_re', 'crossing_im', 'banks', 'time_s', 'status'}), ...
    fullfile(here, 'common_margin.csv'));
