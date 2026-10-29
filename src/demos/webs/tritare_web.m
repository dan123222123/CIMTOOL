%% Networks of vibrating strings: a transcendental NEP with exact eigenvalues
%
% Companion to docs/examples/webs.md up to the orb-weaver section (orb_web.m), one cell per section in page order.
% Cells marked "check" print numbers that the page states in prose.
% Needs nlevp_webs (github.com/jpeterbaker/nlevp_webs) on the MATLAB path.
% Figures go to docs/figures/tritare unless figdir is set before running.

assert(exist('tritare','file') == 2 && exist('general_web','file') == 2, ...
    'tritare_web: nlevp_webs must be on the path (github.com/jpeterbaker/nlevp_webs).');
if ~exist('figdir','var')
    figdir = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', 'docs', 'figures', 'tritare');
end
rng(0);   % the probing directions of every CIM below

%% Plane wave solutions of the 1-D wave equation: eigenvalues of T
% --8<-- [start:planewave]
T = @(s) tan(s) - s;

tol = 10^-6; Ni = 2000; x = linspace(0,20,Ni); ew = zeros(size(x));
for i = 1:length(x)
    ew(i) = fzero(T,x(i));
end
ew = ew(ew > 2); ew = ew(abs(T(ew)) < tol); ew = uniquetol(ew,sqrt(tol));
% --8<-- [end:planewave]

%% Plane wave solutions: plotting (pzT.png, f5ms.png)
% --8<-- [start:planewave_plot]
% T(lambda) with its eigenvalues (dots) and poles (dashed)
poles = (0.5:1:6.5)*pi;  poles = poles(poles <= 20);
xg = linspace(0,20,4000);  yg = tan(xg) - xg;
yg(abs(diff([yg yg(end)])) > 50) = NaN;          % break the curve across poles
f = figure('Position',[100 100 700 525],'Color','w');  hold on
plot(xg, yg, 'b-', 'LineWidth', 1);
for p = poles;  hP = xline(p, 'r--', 'LineWidth', 1);  end
hZ = plot(ew, zeros(size(ew)), 'k.', 'MarkerSize', 22);
hold off;  ylim([-25 25]);  xlim([0 20]);
xlabel('\lambda');  ylabel('T(\lambda) = tan\lambda - \lambda');
legend([hZ hP], {'eigenvalues','poles'}, 'Location','northoutside', ...
    'Orientation','horizontal', 'Box','off');
% --8<-- [end:planewave_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'pzT.png'), 'Resolution', 150);

% --8<-- [start:planewave_modes_plot]
% the first five eigenmodes f(x) = sin(lambda x)
lam5 = ew(1:5);  xf = linspace(0,1,400);  lbl = strings(1,5);
f = figure('Position',[100 100 700 525],'Color','w');  hold on
for k = 1:5
    plot(xf, sin(lam5(k)*xf), 'LineWidth', 1.5);
    lbl(k) = sprintf('\\lambda_%d = %.4f', k, lam5(k));
end
hold off;  ylim([-1 1]);  xlim([0 1]);
xlabel('x');  ylabel('f(x) = sin(\lambda x)');
legend(lbl, 'Location','northoutside', 'Orientation','horizontal', 'Box','off');
% --8<-- [end:planewave_modes_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'f5ms.png'), 'Resolution', 150);

%% The three-string (theta = pi/2): ten eigenvalues vs the 30-digit references
% --8<-- [start:tritare]
[T, TV, gamma, nodes, edges, ew_ref] = tritare(pi/2);   % 12x12, references to 30 digits

op  = Numerics.OperatorData(T);
c   = Numerics.Contour.Circle(2i, 1.5, 512);
cim = Numerics.CIM(op, c);
cim.SampleData.ell = 12;  cim.SampleData.r = 12;
cim.setComputationalMode(Numerics.ComputationalMode.MPLoewner, Numerics.RealizationSize(0, 64));
cim.RealizationData.AutoRank = true;   % m at the largest gap in the singular values of the Loewner matrix

[V, Lam] = cim.eigs();  ew = diag(Lam);
in = c.inside(ew);  ew = ew(in);  V = V(:,in);
res = Numerics.relres(T, ew, V, op.sample_mode);
ok  = res < 1e-8;                      % trusted eigenpairs
fprintf('%d enclosed / %d recovered, %d trusted (rank %d), matching distance %.1e, max relres %.1e\n', ...
    nnz(c.inside(ew_ref)), numel(ew), nnz(ok), cim.ResultData.m, Numerics.matching_distance(ew_ref, ew), max(res));
% --8<-- [end:tritare]

%% The three-string: plotting (tritare_eigs.png, tritare_mode.png)
% --8<-- [start:tritare_plot]
% trusted eigenvalues (dots), untrusted ones (grey squares), 30-digit references (circles) and the contour
f = figure('Position',[100 100 700 525],'Color','w');  hold on
h = [plot([c.z c.z(1)], 'k-', 'LineWidth', 1), ...
     plot(real(ew_ref), imag(ew_ref), 'ko', 'MarkerSize', 9, 'LineWidth', 1), ...
     plot(real(ew(ok)), imag(ew(ok)), 'b.', 'MarkerSize', 20)];
lbl = {'contour','reference','CIM'};
if any(~ok)
    h(end+1) = plot(real(ew(~ok)), imag(ew(~ok)), 's', 'MarkerEdgeColor', [0.6 0.6 0.6], 'MarkerFaceColor', 'none', 'MarkerSize', 7);
    lbl{end+1} = 'relative residual \geq 10^{-8}';
end
hold off;  axis equal;  xlim([-3 3]);  ylim([-0.2 8.2]);
xlabel('Re \lambda');  ylabel('Im \lambda');
legend(h, lbl, 'Location','northoutside', 'Orientation','horizontal', 'Box','off');
% --8<-- [end:tritare_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'tritare_eigs.png'), 'Resolution', 150);

% --8<-- [start:tritare_mode_plot]
% the mode shape of the third eigenpair (omega_3 = 1.55994) via mode_curves
v = V(:,3);  [~, ip] = max(abs(v));  v = real(v / exp(1i*angle(v(ip))));   % rotate to a real vector
R = real(mode_curves(ew(3), v, TV, gamma, nodes, edges, 1, 0, 0.3, 60));
f = figure('Position',[100 100 700 525],'Color','w');  hold on
plot([nodes(edges(:,1),1)' ; nodes(edges(:,2),1)'], ...
     [nodes(edges(:,1),2)' ; nodes(edges(:,2),2)'], '-', 'Color', [0.7 0.7 0.7]);
for i = 1:size(R,3)
    plot(R(1,:,i), R(2,:,i), 'k.-', 'MarkerSize', 16, 'MarkerIndices', 1:3:60);
end
hold off;  axis off;  axis equal;
% --8<-- [end:tritare_mode_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'tritare_mode.png'), 'Resolution', 150);

%% Classifying eigenvalue types on the symmetric tritare: plotting (tritare_types.png)
% --8<-- [start:types_plot]
% one trusted eigenvector of each type, each from a small circle around its frequency
[T, TV, gamma, nodes, edges, ew_ref] = tritare(2*pi/3);
wl = [pi/2, pi/sqrt(2), imag(ew_ref(1))];          % type 1, 2, 3 representatives
opt  = Numerics.OperatorData(T);
ct   = Numerics.Contour.Circle(1i*wl(1), 0.08, 256);
cimt = Numerics.CIM(opt, ct);
cimt.SampleData.ell = 8;  cimt.SampleData.r = 8;
cimt.setComputationalMode(Numerics.ComputationalMode.MPLoewner, Numerics.RealizationSize(0, 64));
cimt.RealizationData.AutoRank = true;
modeV = cell(1,3);
for t = 1:3
    ct.gamma = 1i*wl(t);                           % the shifts follow the circle, the probes stay
    [V, Lam] = cimt.eigs();  z = diag(Lam);
    ok = ct.inside(z) & Numerics.relres(T, z, V, opt.sample_mode) < 1e-8;
    v = V(:, find(ok, 1));
    [~, ip] = max(abs(v));  modeV{t} = real(v / exp(1i*angle(v(ip))));
end

ttl = {'Type 1: transverse  (\omega = \pi/2)', ...
       'Type 2: longitudinal  (\omega = \pi/\surd2)', ...
       'Type 3: junction-moving  (\omega \approx 0.947)'};
scl = [0.30 0.60 0.30];                            % longitudinal needs a larger scale to read
f = figure('Position',[100 100 1200 420],'Color','w');
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');
for t = 1:3
    nexttile;  hold on
    R = real(mode_curves(1i*wl(t), modeV{t}, TV, gamma, nodes, edges, 1, 0, scl(t), 80));
    plot([nodes(edges(:,1),1)' ; nodes(edges(:,2),1)'], ...
         [nodes(edges(:,1),2)' ; nodes(edges(:,2),2)'], '-', 'Color', [0.72 0.72 0.72], 'LineWidth', 1);
    for i = 1:size(R,3)
        plot(R(1,:,i), R(2,:,i), 'k.-', 'MarkerSize', 9, 'LineWidth', 1);
    end
    plot(0, 0, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k');   % the junction
    hold off;  axis equal;  axis off;  title(ttl{t});
end
% --8<-- [end:types_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'tritare_types.png'), 'Resolution', 150);

%% check: the 24 references split 5 / 3 / 16 into types 1 / 2 / 3
w   = imag(ew_ref);  tol = 1e-6;
g3  = @(w) sin(sqrt(2)*w).*cos(2*w) + sqrt(2)*cos(sqrt(2)*w).*sin(2*w);   % type 3, pole-free
typ = zeros(numel(w),1);
for i = 1:numel(w)
    if abs(sin(2*w(i))) < tol, typ(i)=1; elseif abs(sin(sqrt(2)*w(i))) < tol, typ(i)=2;
    elseif abs(g3(w(i))) < tol, typ(i)=3; end
end
fprintf('check: %d refs are type 1: %d, type 2: %d, type 3: %d (%d distinct), unclassified: %d\n', ...
    numel(w), sum(typ==1), sum(typ==2), sum(typ==3), numel(uniquetol(w(typ==3), 1e-8)), sum(typ==0));

%% Realizing eigenpairs: eigenvalue and eigenvector accuracy, all nine modes
% --8<-- [start:pairs]
% the theta = pi/2 CIM, with its contour and probes, on the symmetric operator
[T, ~, ~, ~, ~, ew_ref] = tritare(2*pi/3);
op.T = T;
[V, Lam] = cim.eigs();  ew = diag(Lam);
in = c.inside(ew);  ew = ew(in);  V = V(:,in);
ok = Numerics.relres(T, ew, V, op.sample_mode) < 1e-8;   % trusted eigenpairs

% eigenvalue error, and subspace angle to the analytic eigenspace at the nearest reference
ang = zeros(numel(ew),1);  eer = zeros(numel(ew),1);  jref = zeros(numel(ew),1);
for i = 1:numel(ew)
    [eer(i), jref(i)] = min(abs(ew(i) - ew_ref));
    ang(i) = subspace(V(:,i), null(T(ew_ref(jref(i)))));
end
fprintf('Loewner rank %d, %d eigenvalues, %d trusted; max eigenvalue error %.1e, max eigenvector angle %.1e\n', ...
    cim.ResultData.m, numel(ew), nnz(ok), max(eer), max(ang));

% each double: the recovered pair must span the two-dimensional null space, not just lie in it
for j = unique(jref).'
    pr = find(jref == j);
    if numel(pr) == 2
        N = null(T(ew_ref(j)));
        fprintf('double at %.6fi: pair rank %d, angle between recovered and analytic 2-spaces %.1e\n', ...
            imag(ew_ref(j)), rank(V(:,pr), 1e-8), subspace(V(:,pr), N));
    end
end
% --8<-- [end:pairs]

%% Realizing eigenpairs: plotting (tritare_recovery.png)
% --8<-- [start:pairs_plot]
cls = zeros(numel(ew),1);                           % the type of each recovered eigenvalue
for i = 1:numel(ew)
    ww = imag(ew(i));
    if abs(sin(2*ww)) < 1e-4, cls(i)=1; elseif abs(sin(sqrt(2)*ww)) < 1e-4, cls(i)=2; else cls(i)=3; end
end
cls(~ok) = 4;                                       % untrusted, whatever its type
col = [0.00 0.45 0.74; 0.20 0.60 0.20; 0.85 0.15 0.15; 0.6 0.6 0.6];
mk  = {'.', '.', '.', 's'};  msl = [30 30 30 7];  msr = [26 26 26 7];   % marker sizes, left and right panel
tn  = {'type 1 (transverse)','type 2 (longitudinal)','type 3 (derogatory)','relative residual \geq 10^{-8}'};
f = figure('Position',[100 100 1180 470],'Color','w');
tiledlayout(1,2,'Padding','compact','TileSpacing','loose');

nexttile;  hold on                                 % left: recovered spectrum by type
hC = plot([c.z c.z(1)], 'k-', 'LineWidth', 1);
hR = plot(real(ew_ref), imag(ew_ref), 'o', 'Color',[0.6 0.6 0.6], 'MarkerSize',11, 'LineWidth',1);
h = NaN(1,4);
for i = 1:numel(ew)
    h(cls(i)) = plot(real(ew(i)), imag(ew(i)), mk{cls(i)}, 'MarkerEdgeColor', col(cls(i),:), 'MarkerFaceColor', 'none', 'MarkerSize', msl(cls(i)));
end
hold off;  axis equal;  xlim([-1.7 1.7]);  ylim([-0.2 8.2]);
xlabel('Re \lambda');  ylabel('Im \lambda');  title('recovered spectrum');
lg = [hC hR];  lgs = {'contour','reference'};
for k = 1:4, if ~isnan(h(k)), lg=[lg h(k)]; lgs=[lgs tn(k)]; end, end
legend(lg, lgs, 'Location','northoutside', 'Orientation','horizontal', 'Box','off', 'NumColumns',3);

nexttile;  hold on                                 % right: eigenvector subspace angle
for i = 1:numel(ew)
    stem(imag(ew(i)), max(ang(i),1e-17), 'Color', col(cls(i),:), 'Marker','none', 'LineWidth',1.2);
    plot(imag(ew(i)), max(ang(i),1e-17), mk{cls(i)}, 'MarkerEdgeColor', col(cls(i),:), 'MarkerFaceColor', 'none', 'MarkerSize', msr(cls(i)));
end
yline(eps, 'k:', '\epsilon_{mach}', 'Color',[0.4 0.4 0.4]);
hold off;  set(gca,'YScale','log');  ylim([1e-17 1e0]);  xlim([0.5 3.5]);
xlabel('\omega = Im \lambda');  ylabel('subspace angle to analytic eigenvector (rad)');
title('eigenvector accuracy');
% --8<-- [end:pairs_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'tritare_recovery.png'), 'Resolution', 150);

%% theta as a parameter: eigenvalue trajectories
% --8<-- [start:loci]
% the theta = pi/2 CIM on Circle(2i, 1.5), at every arm angle
th = linspace(pi/6, 5*pi/6, 201);
loci = cell(size(th));  rr = cell(size(th));       % the frequencies inside, and their relative residuals
for k = 1:numel(th)
    op.T = tritare(th(k));
    [V, Lam] = cim.eigs();  z = diag(Lam);  in = c.inside(z);
    loci{k} = imag(z(in));
    rr{k} = Numerics.relres(op.T, z(in), V(:,in), op.sample_mode);
end
ok = vertcat(rr{:}) < 1e-8;                        % trusted eigenpairs
fprintf('theta sweep: %d eigenvalues inside at %d angles, %d trusted, %d untrusted (max relres %.1e)\n', ...
    numel(ok), numel(th), nnz(ok), nnz(~ok), max(vertcat(rr{:})));
% --8<-- [end:loci]

%% theta as a parameter: plotting (tritare_loci.png)
% --8<-- [start:loci_plot]
[~, k3] = min(abs(th - 2*pi/3));
d3 = loci{k3}(diff(loci{k3}) < 1e-6);             % the type-3 doubles at theta = 2*pi/3
TH = repelem(th, cellfun(@numel, loci));  OM = vertcat(loci{:});
band = imag(c.gamma) + [-1 1]*c.rho;              % the frequencies inside the circle
f = figure('Position',[100 100 780 600],'Color','w');  hold on
hB = patch([pi/6 5*pi/6 5*pi/6 pi/6], band([1 1 2 2]), [0.85 0.90 0.97], 'EdgeColor','none', 'FaceAlpha',0.7);
h = [plot(TH(ok), OM(ok), '.', 'Color',[0.15 0.15 0.15], 'MarkerSize', 5), hB, ...
     xline(pi/2,   'b--', 'LineWidth', 1), ...
     xline(2*pi/3, 'r--', 'LineWidth', 1), ...
     plot(2*pi/3*ones(size(d3)), d3, 'ro', 'MarkerSize', 9, 'LineWidth', 1.4)];
lbl = {'eigenvalues', 'inside Circle(2i, 1.5)', ...
    '\theta = \pi/2 (first example)', '\theta = 2\pi/3 (symmetric tritare)', 'type-3 doubles'};
if any(~ok)
    h(end+1) = plot(TH(~ok), OM(~ok), 's', 'MarkerEdgeColor', [0.6 0.6 0.6], 'MarkerFaceColor', 'none', 'MarkerSize', 7);
    lbl{end+1} = 'relative residual \geq 10^{-8}';
end
plot([pi/6 5*pi/6], band([2 2]), 'k-', 'LineWidth', 0.5);
hold off;  xlim([pi/6 5*pi/6]);  ylim([0 4]);
xticks((1:5)*pi/6);  xticklabels({'\pi/6','\pi/3','\pi/2','2\pi/3','5\pi/6'});
xlabel('arm angle  \theta  (radians)');  ylabel('\omega = Im \lambda');
title('eigenvalue trajectories as a function of \theta');
legend(h, lbl, 'Location','northoutside', 'Orientation','horizontal', 'Box','off', 'NumColumns',3);
% --8<-- [end:loci_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'tritare_loci.png'), 'Resolution', 150);

%% check: the theta = pi/2 eigenvalue that leaves Circle(2i, 1.5) crosses omega = 3.5 at theta ~ 1.72
g   = @(t) min(svd(feval(tritare(t), 3.5i)));
tg  = linspace(pi/2, 2*pi/3, 201);  [~, k] = min(arrayfun(g, tg));
th0 = fminbnd(g, tg(max(k-1,1)), tg(min(k+1,end)), optimset('TolX',1e-10));
fprintf('check: a trajectory crosses omega = 3.5 at theta = %.4f (sigma_min %.1e)\n', th0, g(th0));

%% The n-string: multiplicity n-2 at i*pi/2
% --8<-- [start:nstring]
% the n-armed star: n strings of length 2 from a junction at the origin, 4n x 4n
phi  = @(n) 2*pi*(0:n-1)'/n;
star = @(n) general_web([0 0; 2*cos(phi(n)) 2*sin(phi(n))], [(2:n+1)' ones(n,1)], 1, 1, 2, 0);

op  = Numerics.OperatorData(star(3));
c   = Numerics.Contour.Circle(1i*pi/2, 0.1, 256);
cim = Numerics.CIM(op, c);
cim.SampleData.ell = 8;  cim.SampleData.r = 8;
cim.setComputationalMode(Numerics.ComputationalMode.MPLoewner, Numerics.RealizationSize(0, 64));
cim.RealizationData.AutoRank = true;

svals = cell(1,6);                                  % the Loewner singular values, for the plot
for n = 3:6
    op.T = star(n);                                 % a new size draws new probes
    [V, Lam] = cim.eigs();  ew = diag(Lam);
    in = c.inside(ew);  ew = ew(in);  V = V(:,in);
    svals{n} = diag(cim.ResultData.Sigma) / cim.ResultData.Sigma(1);
    res = Numerics.relres(op.T, ew, V, op.sample_mode);
    fprintf('n=%d (T is %2dx%2d): rank %d = n-2, %d trusted, dist to i*pi/2 %.1e, max relres %.1e\n', ...
        n, 4*n, 4*n, cim.ResultData.m, nnz(res < 1e-8), max(abs(ew - 1i*pi/2)), max(res));
end
% --8<-- [end:nstring]

%% The n-string: plotting (nstar_mult.png)
% --8<-- [start:nstring_plot]
f = figure('Position',[100 100 700 525],'Color','w');  hold on
lbl = strings(1,4);
for n = 3:6
    kk = 1:min(10, numel(svals{n}));
    semilogy(kk, svals{n}(kk), 'o-', 'LineWidth', 1.2, 'MarkerSize', 6);
    lbl(n-2) = sprintf('n = %d  (mult %d)', n, n-2);
end
hold off;  set(gca,'YScale','log');  ylim([1e-16 2]);  xlim([1 10]);
xlabel('index k');  ylabel('\sigma_k / \sigma_1');
legend(lbl, 'Location','northoutside', 'Orientation','horizontal', 'Box','off');
% --8<-- [end:nstring_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'nstar_mult.png'), 'Resolution', 150);

%% Probing directions bound the recoverable multiplicity
% --8<-- [start:probing]
% the n = 6 star of the loop above, realized from two of its probes per side
cim.SampleData.ell = 2;  cim.SampleData.r = 2;
cim.compute();
fprintf('n=6 with ell = r = 2: Loewner rank %d (true multiplicity 4)\n', cim.ResultData.m);
% --8<-- [end:probing]
