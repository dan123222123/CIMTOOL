%% Experiment 2: delay margin with a single delayed stabiliser
%
% Loop k alone is delayed, tau = r*e_k, and the other nine stay undelayed. The
% margin of each direction comes from the base bank (pes39_bank.m, MPLoewner,
% five probing directions) through pes39_margin.m, which returns Inf when
% nothing crosses by 500 ms. Writes single_margin.csv; status is "ok", "jump"
% when the rightmost trusted eigenvalue at the margin is off the axis, or "none"
% when nothing crosses.

here = fileparts(mfilename('fullpath'));
[~, ~, ~, Tf] = pes39_model();
bank = pes39_bank(Tf);

rows = cell(10, 7);
for k = 1:10
    u = zeros(10,1);  u(k) = 1;
    t = tic;  [tc, zc, nb] = pes39_margin(bank, u);
    status = "ok";
    if ~isfinite(tc), status = "none"; elseif abs(real(zc)) > 1e-6, status = "jump"; end
    rows(k, :) = {k, 1e3*tc, real(zc), imag(zc), nb, toc(t), status};
    fprintf('delayed loop %2d: margin %7.2f ms, crossing %+.5f%+.5fi, %s  (%d banks, %.0f s)\n', ...
        k, 1e3*tc, real(zc), imag(zc), status, nb, toc(t));
end
writetable(cell2table(rows, 'VariableNames', {'delayed_loop', 'margin_ms', 'crossing_re', 'crossing_im', 'banks', 'time_s', 'status'}), ...
    fullfile(here, 'single_margin.csv'));
