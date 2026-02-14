% generic imports
import Visual.*;

%% PEEC model from Milano et al.
delay_3bus;
H = @(s,tau) s*eye(23) - A0 - A1*exp(-s*tau);
H0 = @(s) H(s,0);

%% first experiment -- how many eigenvalues can we get on subsets of a vertical strip in C?

% make the CIM
n = OperatorData(H0); c = Contour.Circle(0,10,4096); %n.sample_mode = Numerics.SampleMode.Direct;
cim = CIM(n,c); cim.auto_update_shifts = true;
cim.ax = gca;
% CIMTOOL(cim);
%
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
cim.RealizationData.m = 9; cim.RealizationData.K = 100;
cim.SampleData.ell = 100; cim.SampleData.r = 100;
cim.compute();
%
currank = rank(cim.ResultData.Db,1e-9);
cim.RealizationData.m = currank;
[V,Lambda] = cim.eigs();
max(Numerics.relres(H0,diag(Lambda),V,n.sample_mode))

%% third experiment -- vary the time-dependant parameter with a fixed contour to try to find a rightmost eigenvalue
figure(2); clf; hold on; taul = linspace(0,1,50);

gifFile = 'delay_ew_trajectory.gif';

for i=1:length(taul)

    cT = @(s) H(s,taul(i));
    n = OperatorData(cT);
    cim = CIM(n,c); cim.auto_update_shifts = true;
    % cim.ax = gca;
    %
    cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
    cim.RealizationData.m = 1; cim.RealizationData.K = 100; cim.SampleData.ell = 5; cim.SampleData.r = 5;
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
    % max(real(diag(Lambda)))

    title(sprintf("tau = %f",taul(i)));
    xlim([-5,5]); ylim([-10,10]);
    drawnow; exportgraphics(gca, gifFile, Append=true);

end
hold off;