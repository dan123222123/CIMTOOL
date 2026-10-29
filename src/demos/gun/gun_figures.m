%% Figure of the gun example, from the CSVs of gun_nlevp.m

% --8<-- [start:plot]
here = fileparts(mfilename('fullpath'));
res = readtable(fullfile(here, 'gun_residuals.csv'));
sv = readtable(fullfile(here, 'gun_singular_values.csv'));
P = readtable(fullfile(here, 'gun_points.csv'));
S = readtable(fullfile(here, 'gun_eigenvalues.csv'));
ctr = 141000;  rho = 30000;  m = 17;
CASES = [2 16; 4 8; 8 4];
SVN = [128 512];
c = ctr + rho*exp(1i*linspace(0, 2*pi, 2000));

meth = ["hankel", "sploewner", "mploewner"];
label = ["Hankel", "single-point Loewner", "multipoint Loewner"];
color = {[0 0.447 0.741], [0.850 0.325 0.098], [0.466 0.674 0.188]};
mark = ['>', 'o', 'p'];

ncase = size(CASES, 1);
f = figure('Color', 'w', 'Position', [100 100 1200 1350]);
% nested layouts, so that each block has its own legend above it
tl = tiledlayout(f, 2 + numel(SVN), 1, 'TileSpacing', 'compact', 'Padding', 'compact');
top = tiledlayout(tl, 1, ncase, 'TileSpacing', 'compact');
top.Layout.Tile = 1;
bottom = tiledlayout(tl, 1 + numel(SVN), ncase, 'TileSpacing', 'compact');
bottom.Layout.Tile = 2;  bottom.Layout.TileSpan = [1 + numel(SVN), 1];
for k = 1:ncase
    K = CASES(k, 1);  tag = sprintf('K%dr%d', CASES(k, :));

    ax = nexttile(top, k);  hold(ax, 'on');  grid(ax, 'on');  box(ax, 'on');
    plot(ax, real(c), imag(c), 'k-', 'HandleVisibility', 'off');
    hp(1) = plot(ax, S.re, S.im, 'k.', 'MarkerSize', 12, 'DisplayName', 'eigenvalues');
    hp(2) = plot(ax, P.(sprintf('sigma_re_K%d', K)), P.(sprintf('sigma_im_K%d', K)), '+', 'Color', color{3}, ...
        'MarkerSize', 8, 'LineWidth', 1.25, 'DisplayName', 'right points \sigma_j');
    hp(3) = plot(ax, P.(sprintf('theta_re_K%d', K)), P.(sprintf('theta_im_K%d', K)), 'x', 'Color', color{3}, ...
        'MarkerSize', 8, 'LineWidth', 1.25, 'DisplayName', 'left points \theta_i');
    hp(4) = plot(ax, P.sp_re, P.sp_im, '*', 'Color', color{2}, 'MarkerSize', 8, 'DisplayName', 'single-point \sigma');
    xlim(ax, ctr + 46000*[-1 1]);  ylim(ax, 46000*[-1 1]);  daspect(ax, [1 1 1]);
    xlabel(ax, 'Re \lambda');  if k == 1, ylabel(ax, 'Im \lambda'); end
    title(ax, sprintf('(K, r) = (%d, %d)', CASES(k, :)));
    if k == 1
        lg = legend(ax, hp, 'Orientation', 'horizontal');  lg.Layout.Tile = 'north';
    end

    ax = nexttile(bottom, k);  hold(ax, 'on');  grid(ax, 'on');  box(ax, 'on');
    for j = 1:numel(meth)
        plot(ax, res.N, res.(meth(j) + "_" + tag), '-', 'Color', color{j}, 'Marker', mark(j), ...
            'MarkerFaceColor', color{j}, 'MarkerSize', 5, 'LineWidth', 1.25, 'DisplayName', label(j));
    end
    set(ax, 'XScale', 'log', 'YScale', 'log', 'XTick', res.N);  xlim(ax, res.N([1 end]));  ylim(ax, [1e-18 1e-2]);
    xlabel(ax, 'N');  if k == 1, ylabel(ax, 'max relative residual'); end
    if k == 1
        lg = legend(ax, 'Orientation', 'horizontal');  lg.Layout.Tile = 'north';
    end

    for i = 1:numel(SVN)
        ax = nexttile(bottom, i*ncase + k);  hold(ax, 'on');  grid(ax, 'on');  box(ax, 'on');
        for j = 1:numel(meth)
            plot(ax, sv.k, sv.(meth(j) + "_" + tag + "_N" + SVN(i)), '-', 'Color', color{j}, 'Marker', mark(j), ...
                'MarkerFaceColor', color{j}, 'MarkerSize', 4);
        end
        xline(ax, m + 0.5, ':', sprintf('m = %d', m), 'Color', [0.4 0.4 0.4], 'LabelVerticalAlignment', 'bottom');
        set(ax, 'YScale', 'log');  xlim(ax, [0 height(sv) + 1]);  ylim(ax, [1e-20 2]);
        xlabel(ax, 'k');  if k == 1, ylabel(ax, sprintf('\\sigma_k/\\sigma_1, N = %d', SVN(i))); end
    end
end
fontsize(f, 10, "points");
% --8<-- [end:plot]
outdir = fullfile(here, '..', '..', '..', 'docs', 'figures', 'gun');
theme(f, "light");
exportgraphics(f, fullfile(outdir, 'methods.png'), 'Resolution', 150);
