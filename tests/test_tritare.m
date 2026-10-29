%% Test CIM against the tritare's exact (30-digit) transcendental spectrum
% The tritare (jpeterbaker/nlevp_webs) is a 12x12 trigonometric NEP for a
% Y-shaped string network, with reference eigenvalues to 30 digits -- the only
% test in this suite with exact transcendental ground truth. Also exercises
% multiple eigenvalues: the Loewner rank must count multiplicity.
%
% SKIPS (passes vacuously) if nlevp_webs is not on the path; see
% https://github.com/jpeterbaker/nlevp_webs

clear; close all;
addpath(genpath('../src'));
webs = fullfile(getenv('HOME'), 'MATLAB Add-Ons', 'Collections', 'nlevp_webs');
if exist(webs, 'dir'), addpath(webs); end
if exist('tritare', 'file') ~= 2 || exist('general_web', 'file') ~= 2
    fprintf('SKIP: nlevp_webs not found on path -- test_tritare not run\n');
    return
end
import Visual.*

%% Test 1: theta = pi/2 -- ten simple eigenvalues vs 30-digit references
fprintf('Test 1: tritare theta=pi/2 vs 30-digit references\n');
[T, ~, ~, ~, ~, ew_ref] = tritare(pi/2);

c   = Contour.Circle(2i, 1.5, 512);
cim = CIM(OperatorData(T), c);  cim.auto_update_shifts = true;
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
cim.RealizationData.K = 64;  cim.SampleData.ell = 12;  cim.SampleData.r = 12;
cim.compute();

s = svd(full(cim.ResultData.Db));  s = s/s(1);
m = find(s > 1e-10, 1, 'last');
cim.RealizationData.m = m;
[V, Lam] = cim.eigs();  ew = diag(Lam);
in = abs(ew - 2i) < 1.5;  ew = ew(in);  V = V(:,in);
res = Numerics.relres(T, ew, V, cim.SampleData.OperatorData.sample_mode);

ref_in = ew_ref(abs(ew_ref - 2i) < 1.5);
assert(numel(ref_in) == 10 && numel(ew) == 10, ...
    'expected 10 eigenvalues enclosed/recovered, got %d/%d', numel(ref_in), numel(ew));
dist = arrayfun(@(z) min(abs(z - ew)), ref_in);
assert(max(dist) < 1e-12, 'max dist to reference %.1e >= 1e-12', max(dist));
assert(max(res) < 1e-12, 'max relres %.1e >= 1e-12', max(res));
fprintf('  10/10 recovered, max dist %.1e, max relres %.1e\n', max(dist), max(res));

%% Test 2: theta = 2pi/3 -- double eigenvalue counted by the Loewner rank
fprintf('Test 2: symmetric tritare -- classification + nine low eigenvalues\n');
[T, ~, ~, ~, ~, ew_ref] = tritare(2*pi/3);

% (a) the three closed-form families classify every 30-digit reference: 5/3/16
w  = imag(ew_ref);
g3 = @(w) sin(sqrt(2)*w).*cos(2*w) + sqrt(2)*cos(sqrt(2)*w).*sin(2*w);   % type-3, pole-free
typ = zeros(24,1);
for i = 1:24
    if abs(sin(2*w(i))) < 1e-6, typ(i)=1; elseif abs(sin(sqrt(2)*w(i))) < 1e-6, typ(i)=2;
    elseif abs(g3(w(i))) < 1e-6, typ(i)=3; end
end
assert(isequal([sum(typ==1) sum(typ==2) sum(typ==3) sum(typ==0)], [5 3 16 0]), ...
    'type classification %d/%d/%d/%d ~= 5/3/16/0', sum(typ==1), sum(typ==2), sum(typ==3), sum(typ==0));

% (b) one contour recovers the nine low eigenvalues (three derogatory doubles
% counted by the Loewner rank), with eigenvalues AND eigenvectors at machine precision
c   = Contour.Circle(2i, 1.5, 512);
cim = CIM(OperatorData(T), c);  cim.auto_update_shifts = true;
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
cim.RealizationData.K = 64;  cim.SampleData.ell = 12;  cim.SampleData.r = 12;
cim.compute();

s = svd(full(cim.ResultData.Db));  s = s/s(1);
m = find(s > 1e-10, 1, 'last');
assert(m == 9, 'Loewner rank %d ~= 9', m);
cim.RealizationData.m = m;
[V, Lam] = cim.eigs();  ew = diag(Lam);
in = abs(ew - 2i) < 1.5;  ew = ew(in);  V = V(:,in);
assert(numel(ew) == 9, 'expected 9 eigenvalues recovered, got %d', numel(ew));
ang = zeros(numel(ew),1);  eer = zeros(numel(ew),1);
for i = 1:numel(ew)
    [eer(i), j] = min(abs(ew(i) - ew_ref));
    ang(i) = subspace(V(:,i), null(T(ew_ref(j))));   % recovered vs analytic eigenspace
end
assert(max(eer) < 1e-12, 'max eigenvalue error %.1e >= 1e-12', max(eer));
assert(max(ang) < 1e-10, 'max eigenvector subspace angle %.1e >= 1e-10', max(ang));
fprintf('  5/3/16 classified, rank 9, max eig error %.1e, max eigenvector angle %.1e\n', ...
    max(eer), max(ang));

%% Test 3: 5-armed star -- multiplicity n-2 = 3 at exactly i*pi/2
fprintf('Test 3: symmetric 5-star, multiplicity 3 at i*pi/2\n');
n = 5;
phi   = 2*pi*(0:n-1)'/n;
nodes = [0 0; 2*cos(phi) 2*sin(phi)];
edges = [(2:n+1)' ones(n,1)];
Tn    = general_web(nodes, edges, 1, 1, 2, 0);

c   = Contour.Circle(1i*pi/2, 0.1, 256);
cim = CIM(OperatorData(Tn), c);  cim.auto_update_shifts = true;
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
cim.RealizationData.K = 64;  cim.SampleData.ell = 8;  cim.SampleData.r = 8;
cim.compute();

s = svd(full(cim.ResultData.Db));  s = s/s(1);
m = find(s > 1e-10, 1, 'last');
assert(m == n-2, 'Loewner rank %d ~= n-2 = %d', m, n-2);
cim.RealizationData.m = m;
[~, Lam] = cim.eigs();  ew = diag(Lam);
ew = ew(abs(ew - 1i*pi/2) < 0.1);
assert(numel(ew) == n-2 && max(abs(ew - 1i*pi/2)) < 1e-12, ...
    'multiplicity-3 eigenvalue at i*pi/2 not recovered');
fprintf('  rank %d = n-2, all copies at i*pi/2 to %.1e\n', m, max(abs(ew - 1i*pi/2)));

fprintf('test_tritare: all tests passed\n');
