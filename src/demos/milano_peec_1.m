L = 100*[-7 1 2; 3 -9 0; 1 2 -6];
M = 100*[1 0 -3; -0.5 -0.5 -1; -0.5 -1.5 0];
N = [-1 5 2; 4 0 3; -2 4 1]/72;
I = eye(3);

% spliting up all of the parts to be explicit
H = @(s,tau) (I - N*exp(-s*tau));
T = @(s,tau) s*H(s,tau) - L - M*exp(-s*tau);

% first test tau = 1
H1 = @(s) H(s,1);
T1 = @(s) T(s,1);

%% first experiment -- how many eigenvalues can we get on subsets of a vertical strip in C?

% make the CIM
n = OperatorData(T1);
c = Contour.Ellipse(0,2,10,1e4);
cim = CIM(n,c); cim.auto_update_shifts = true;
cim.ax = gca;
%
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
cim.RealizationData.m = 1; cim.RealizationData.K = 500;
cim.SampleData.ell = 50; cim.SampleData.r = 50;
cim.compute();

bl = linspace(10,100,10); mrc = 0;

for i=1:length(bl)
    c.beta = bl(i); cim.RealizationData.m = 1; cim.compute();
    %
    cim.RealizationData.m = rank(cim.ResultData.Db,1e-8);
    [V,Lambda] = cim.eigs();
    crr = max(Numerics.relres(T1,diag(Lambda),V,n.sample_mode))
    if(crr > 1e-8 && mrc < 4)
        cim.refineQuadrature();
        mrc = mrc + 1;
    end
    %
    drawnow;
end

%% second experiment -- scan the imaginary axis for additional eigenvalues

% make the CIM
n = OperatorData(T1);
c = Contour.Ellipse(0,2,100,1e4);
cim = CIM(n,c); cim.auto_update_shifts = true;
cim.ax = gca;
%
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
cim.RealizationData.m = 1; cim.RealizationData.K = 500;
cim.SampleData.ell = 50; cim.SampleData.r = 50;
cim.compute();

gl = 0:50:600; title("tau = 1");

gifFile = 'posiR_scan.gif';
exportgraphics(gca, gifFile);

for i=1:length(gl)
    c.gamma = gl(i)*1i; % positive imaginary axis
    % c.gamma = -gl(i)*1i; % negative imaginary axis
    %
    cim.RealizationData.m = 1;
    try
        cim.compute();
    catch e
        continue;
    end
    %
    currank = rank(cim.ResultData.Db,1e-8);
    if currank == 0
        continue;
    end
    cim.RealizationData.m = currank;
    [V,Lambda] = cim.eigs();
    max(Numerics.relres(T1,diag(Lambda),V,n.sample_mode))
    %
    drawnow; exportgraphics(gca, gifFile, Append=true);
end

%% third experiment -- vary the time-dependant parameter with a fixed contour to try to find a rightmost eigenvalue
figure(2); clf; hold on;
taul = linspace(1,1e4,50); c = Contour.Circle(600i,1,1e3);

for i=1:length(taul)

    cT = @(s) T(s,taul(i));
    n = OperatorData(cT);
    cim = CIM(n,c); cim.auto_update_shifts = true;
    % cim.ax = gca;
    %
    cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
    cim.RealizationData.m = 1; cim.RealizationData.K = 100; cim.SampleData.ell = 100; cim.SampleData.r = 100;
    try
        cim.compute();
    catch e
        continue;
    end
    %
    currank = rank(cim.ResultData.Db,1e-8);
    if currank == 0
        continue;
    end
    if currank > 20
        c.rho = c.rho / 10; continue;
    end
    cim.RealizationData.m = currank; [V,Lambda] = cim.eigs();
    scatter(real(diag(Lambda)),imag(diag(Lambda)));

    max(Numerics.relres(cT,diag(Lambda),V,n.sample_mode))
    max(real(diag(Lambda)))

    title(sprintf("tau = %f",taul(i)));
    drawnow;
end
hold off;
