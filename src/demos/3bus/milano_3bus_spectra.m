%% Spectra of the three-bus system with and without the PSS, no delay
%
% nopss: eig(As), the 19 states of Milano's Appendix B.
% pss:   eig(A0 + A1), the 23 states with the PSS of Example 11.1 at tau = 0.
% Writes spectra.csv (system, re, im) next to this script.

here = fileparts(mfilename('fullpath'));
milano_3bus_ex11_1;
ew = {eig(A0 + A1), eig(As)};
names = ["pss", "nopss"];
S = table();
for j = 1:2
    S = [S; table(repmat(names(j), numel(ew{j}), 1), real(ew{j}), imag(ew{j}), ...
        'VariableNames', {'system', 're', 'im'})];
end
writetable(S, fullfile(here, 'spectra.csv'));
for j = 1:2
    z = ew{j};
    fprintf('%-5s n = %2d, rightmost oscillatory %s\n', names(j), numel(z), ...
        num2str(max(z(imag(z) > 1e-3), [], 'ComparisonMethod', 'real')));
end
