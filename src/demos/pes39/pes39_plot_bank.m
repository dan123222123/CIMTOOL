function ax = pes39_plot_bank(ew, opts)
% Plot the disk wall of pes39_bank.m and the eigenvalues it returned: stable
% ones as crosses, ones with positive real part as filled circles. Pass the
% same Centers and Radius as to pes39_bank. Trajectory adds further
% eigenvalues as small dots coloured by TrajectoryTau, for instance every
% eigenvalue of a delay sweep. Untrusted adds eigenvalues the bank does not
% trust as empty grey boxes, with a legend entry. YLim crops the wall; the
% default shows all of it.
arguments
    ew (:,1) double = []
    opts.Centers (1,:) double = 3:12
    opts.Radius (1,1) double = 1
    opts.Axes = gca
    opts.Title (1,:) char = ''
    opts.YLim (1,:) double = []
    opts.Trajectory (:,1) double = []
    opts.TrajectoryTau (:,1) double = []
    opts.Untrusted (:,1) double = []
end
ax = opts.Axes;  hold(ax, 'on');  r = opts.Radius;
th = linspace(0, 2*pi, 200);
for c = opts.Centers
    plot(ax, r*cos(th), c + r*sin(th), '-', 'Color', [0.72 0.74 0.78], 'LineWidth', 0.75);
end
xline(ax, 0, 'k-', 'LineWidth', 0.75);
hu = plot(ax, real(opts.Untrusted), imag(opts.Untrusted), 's', 'LineStyle', 'none', ...
    'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0.6 0.6 0.6], 'MarkerSize', 5);
if ~isempty(opts.Trajectory)
    scatter(ax, real(opts.Trajectory), imag(opts.Trajectory), 10, opts.TrajectoryTau, 'filled');
    cb = colorbar(ax);  cb.Label.String = '\tau [ms]';
end
s = real(ew) <= 0;
plot(ax, real(ew(s)), imag(ew(s)), 'x', 'Color', [0 0.33 0.71], 'MarkerSize', 7, 'LineWidth', 1.25);
plot(ax, real(ew(~s)), imag(ew(~s)), 'o', 'Color', [0.8 0.1 0.1], 'MarkerFaceColor', [0.8 0.1 0.1], 'MarkerSize', 6);
daspect(ax, [1 1 1]);
if isempty(opts.YLim), opts.YLim = [min(opts.Centers) - 1.2*r, max(opts.Centers) + 1.2*r]; end
xlim(ax, 1.6*[-r r]);  ylim(ax, opts.YLim);
xlabel(ax, 'Re \lambda');  ylabel(ax, 'Im \lambda');  title(ax, opts.Title);  box(ax, 'on');
if ~isempty(opts.Untrusted)
    legend(ax, hu, 'relative residual \geq 10^{-8}', 'Interpreter', 'tex', 'Location', 'southoutside');
end
end
