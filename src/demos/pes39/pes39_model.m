function [A0, B, E, T] = pes39_model(cachedir)
% Delay model of the IEEE PES 39-bus benchmark with one delay per stabiliser:
%
%     T(lambda; tau) = lambda I - A0 - B diag(exp(-lambda tau)) E',
%
% n = 100 live states, ten PSS feedback loops. Loop k feeds the speed of generator
% k (column k of E selects it) back through the five entries in column k of B.
% T(tau) returns the characteristic matrix for a delay vector tau (10 x 1).
%
% The data are the small-disturbance "MATLAB Files" of the IEEE 39 Bus System
% (Hiskens, 2013) on the PES PSDP benchmark page,
% https://cmte.ieee.org/pes-psdp/benchmark-systems-2/ , downloaded into
% cachedir on first use.

arguments
    cachedir = fullfile(fileparts(mfilename('fullpath')), 'cache')
end
A = loadfirst(fetch(cachedir));

gen = 1:40;
exc = reshape(110 + 5*(0:9) + (0:2)', 1, []);
pss = reshape(160 + 5*(0:9) + (0:2)', 1, []);
live = sort([gen exc pss]);
assert(numel(live) == 100 && all(any(A(live,:), 2)) && ~any(any(A(setdiff(1:209, live), :))), ...
    'pes39_model:layout', 'live-state layout does not match Ared');

Al = A(live, live);
omega = 4*(1:10);
[~, w] = ismember(omega, live);
B = zeros(100, 10);
for k = 1:10
    rows = [110 + 5*(k-1) + (1:2), 160 + 5*(k-1) + (0:2)];      % Efd, xi; xW, xP, xQ
    [~, r] = ismember(rows, live);
    assert(nnz(A(setdiff(1:209, [4*k-1 rows]), omega(k))) == 0, ...
        'pes39_model:speed', 'unexpected coupling of omega_%d', k);
    B(r, k) = Al(r, w(k));
end
E = zeros(100, 10);  E(sub2ind([100 10], w, 1:10)) = 1;
A0 = Al - B*E';

% --8<-- [start:model]
% T(tau) is the characteristic matrix for the delay vector tau (10 x 1)
n = size(A0,1);
T = @(tau) @(s) s*eye(n) - A0 - B*diag(exp(-s*tau(:)))*E';
% --8<-- [end:model]
end

function file = fetch(cachedir)
% the legacy Drive ID needs its resource key, else Drive serves a sign-in page
id  = '0Bys96O_8YuIbWGFBZThqcHAxMmc';
key = '0-sngDY8yGNrhzyhyY7Fl-FQ';
file = fullfile(cachedir, 'Ared.mat');
if isfile(file), return; end
if ~isfolder(cachedir), mkdir(cachedir); end
zipfile = fullfile(cachedir, 'smallsignal.zip');
websave(zipfile, sprintf('https://drive.google.com/uc?export=download&id=%s&resourcekey=%s', id, key));
unzip(zipfile, cachedir);
end

function v = loadfirst(file)
c = struct2cell(load(file));  v = c{1};
end
