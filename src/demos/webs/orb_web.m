%% An orb-weaver's web: the string-network NEP at its natural scale
%
% Companion to the orb-weaver section of docs/examples/webs.md; tritare_web.m covers the rest of the page.
% nlevp_webs' spider2 is a traced orb-weaver web whose planar vibrations give a 4964 x 4964 trigonometric NEP, with its 24 lowest eigenvalues to 8 digits.
% The cell marked "check" prints numbers that the page states in prose.
% Needs nlevp_webs (github.com/jpeterbaker/nlevp_webs) on the MATLAB path.
% Figures go to docs/figures/tritare unless figdir is set before running.

assert(exist('spider2', 'file') == 2, ...
    'orb_web: nlevp_webs must be on the path (github.com/jpeterbaker/nlevp_webs).');
if ~exist('figdir','var')
    figdir = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', 'docs', 'figures', 'tritare');
end
rng(0);   % the probing directions

%% Two lowest modes of the 4964x4964 web
tic;
% --8<-- [start:orb]
[Td, TV, gam, nodes, edges, ew_ref] = spider2();
T = @(s) sparse(Td(s));                            % assembled dense, but string-local: sample it sparse

op  = Numerics.OperatorData(T);
c   = Numerics.Contour.Circle(0.0278i, 0.005, 128);   % encloses the two lowest modes
cim = Numerics.CIM(op, c);
cim.SampleData.ell = 8;  cim.SampleData.r = 8;
cim.setComputationalMode(Numerics.ComputationalMode.MPLoewner, Numerics.RealizationSize(0, 48));
cim.RealizationData.AutoRank = true;

[V, Lam] = cim.eigs();  ew = diag(Lam);
in = c.inside(ew);  ew = ew(in);  V = V(:,in);
res = Numerics.relres(T, ew, V, op.sample_mode);
ok  = res < 1e-8;                                  % trusted eigenpairs
fprintf('Loewner rank %d; %d web modes inside, %d trusted:\n', cim.ResultData.m, numel(ew), nnz(ok));
for k = 1:numel(ew)
    fprintf('   %.8fi   relres %.1e   dist to 8-digit ref %.1e\n', ...
        imag(ew(k)), res(k), min(abs(ew(k) - ew_ref)));
end
% --8<-- [end:orb]
t_cim = toc;

%% check: web size, sparsity, the dense-sample estimate, and the run time
n = op.n;
fprintf('check: %d nodes, %d edges, T is %dx%d and %.2f%% dense; dense n x n x 48 samples = %.1f GB; loading, sampling and realization took %.0f s\n', ...
    size(nodes,1), size(edges,1), n, n, 100*nnz(T(0.02i))/n^2, 16*n^2*48/1e9, t_cim);

%% Spectrum: plotting (orb_spectrum.png)
% --8<-- [start:orb_spectrum_plot]
f = figure('Position',[100 100 900 300],'Color','w');  hold on
h = [plot(imag([c.z c.z(1)]), real([c.z c.z(1)]), 'k-', 'LineWidth', 1), ...   % the contour, axes swapped
     plot(imag(ew_ref), real(ew_ref), 'ko', 'MarkerSize', 8, 'LineWidth', 1), ...
     plot(imag(ew(ok)), real(ew(ok)), 'b.', 'MarkerSize', 18)];
lbl = {'contour','reference (8 digits)','CIM'};
if any(~ok)
    h(end+1) = plot(imag(ew(~ok)), real(ew(~ok)), 's', 'MarkerEdgeColor', [0.6 0.6 0.6], 'MarkerFaceColor', 'none', 'MarkerSize', 7);
    lbl{end+1} = 'relative residual \geq 10^{-8}';
end
yline(0, ':', 'Color', [0.6 0.6 0.6]);
hold off;  axis equal;  xlim([0 0.17]);  ylim([-0.012 0.012]);
xlabel('Im \lambda');  ylabel('Re \lambda');
legend(h, lbl, 'Location','northoutside', 'Orientation','horizontal', 'Box','off');
% --8<-- [end:orb_spectrum_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'orb_spectrum.png'), 'Resolution', 150);

%% Fundamental mode shape: plotting (orb_mode.png)
% --8<-- [start:orb_mode_plot]
v1 = V(:,1);  [~, imx] = max(abs(v1));  v1 = real(v1 * exp(-1i*angle(v1(imx))));   % rotate to a real vector
R = real(mode_curves(ew(1), v1, TV, gam, nodes, edges, 1, 0, 0.5, 20));
f = figure('Position',[100 100 900 800],'Color','w');  hold on
plot([nodes(edges(:,1),1)' ; nodes(edges(:,2),1)'], ...
     [nodes(edges(:,1),2)' ; nodes(edges(:,2),2)'], '-', 'Color', [0.75 0.75 0.75]);
for i = 1:size(R,3)
    plot(R(1,:,i), R(2,:,i), 'k-', 'LineWidth', 0.5);
end
hold off;  axis off;  axis equal;
% --8<-- [end:orb_mode_plot]
theme(f, "light");  exportgraphics(f, fullfile(figdir, 'orb_mode.png'), 'Resolution', 150);
