%% Experiment 3: delay margin with one stabiliser undelayed
%
% Loop k keeps tau_k = 0 and the other nine share one delay r, so
% tau = r*(1 - e_k). The margin of each direction comes from the base bank
% (pes39_bank.m, MPLoewner, five probing directions) through pes39_margin.m, next
% to the margin with all ten loops delayed (undelayed_loop = 0 in the table).
% Writes dropone.csv.

here = fileparts(mfilename('fullpath'));
[~, ~, ~, Tf] = pes39_model();
bank = pes39_bank(Tf);

rows = zeros(11, 6);
for k = 0:10
    u = ones(10,1);  if k > 0, u(k) = 0; end
    t = tic;  [tc, zc, nb] = pes39_margin(bank, u);
    rows(k+1, :) = [k, 1e3*tc, real(zc), imag(zc), nb, toc(t)];
    fprintf('undelayed loop %2d: margin %7.2f ms, crossing %+.5f%+.5fi  (%d banks, %.0f s)\n', k, 1e3*tc, real(zc), imag(zc), nb, toc(t));
end
writetable(array2table(rows, 'VariableNames', {'undelayed_loop', 'margin_ms', 'crossing_re', 'crossing_im', 'banks', 'time_s'}), ...
    fullfile(here, 'dropone.csv'));
