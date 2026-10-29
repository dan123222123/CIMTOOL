%% Spectra of the PES 39-bus model with and without the stabilisers, no delay
%
% pss:   eig(A0 + B*E'), the 100 live states with every loop closed.
% nopss: the 70 generator and exciter states of A0. A0 removes the speed input
%        of every stabiliser, after which the stabiliser states only filter
%        themselves (eigenvalues -1/TW, -1/T2, -1/T4) and drop out.
% Writes spectra.csv (system, re, im) next to this script.

here = fileparts(mfilename('fullpath'));
[A0, B, E] = pes39_model();
% live states are ordered generators (1:40), exciters (41:70), stabilisers (71:100)
genexc = 1:70;
ew = {eig(A0 + B*E'), eig(A0(genexc, genexc))};
names = ["pss", "nopss"];
T = table();
for j = 1:2
    T = [T; table(repmat(names(j), numel(ew{j}), 1), real(ew{j}), imag(ew{j}), ...
        'VariableNames', {'system', 're', 'im'})];
end
writetable(T, fullfile(here, 'spectra.csv'));
for j = 1:2
    z = ew{j};
    fprintf('%-5s n = %3d, Re in [%.4g, %.4g], |Im| <= %.4g, rightmost oscillatory %s\n', names(j), numel(z), ...
        min(real(z)), max(real(z)), max(abs(imag(z))), num2str(max(z(abs(imag(z)) > 1e-3), [], 'ComparisonMethod', 'real')));
end
