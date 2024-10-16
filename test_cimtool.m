%c = GUI.CIMTOOL();
c.CIMData.MainAx.DataAspectRatioMode = "auto";
c.CIMData.SampleData.NLEVP.loadNLEVPpack('plasma_drift');
c.CIMData.SampleData.NLEVP.compute_reference = true;
c.CIMData.RealizationData.K = 18;
c.CIMData.RealizationData.m = 6;
c.CIMData.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

% try with different repeated sampling of directions and >< N
rsamp = 1; c.CIMData.SampleData.ell = rsamp; c.CIMData.SampleData.r = rsamp;
c.CIMData.SampleData.Contour.N = 64;

c.CIMData.RealizationData.ShiftScale = 1.5;
c.CIMData.interlevedshifts()
c.CIMData.SampleData.Contour.center = -0.4+0.16i;
c.CIMData.SampleData.Contour.radius = 0.3;
c.CIMData.auto_update_shifts = false;

%c.CIMData.compute()
%c.CIMData.auto = false;

y = linspace(0,2,100); steps = length(y);
% y = linspace(1,2,100); steps = length(y);
% ict = 2; ics = 3;
thetai = c.CIMData.RealizationData.InterpolationData.theta;
sigmai = c.CIMData.RealizationData.InterpolationData.sigma;
ICi = [thetai sigmai];
E = rand(2);
% ictinit = c.CIMData.RealizationData.InterpolationData.theta(ict);
% icsinit = c.CIMData.RealizationData.InterpolationData.sigma(ics);
for i=1:length(y)
    %c.CIMData.SampleData.Contour.center = centersteps(i);
    ICc = ICi * (eye(2)+y(i)*E);
    thetac = ICc(:,1);
    sigmac = ICc(:,2);
    c.CIMData.RealizationData.InterpolationData = Numerics.InterpolationData(thetac,sigmac);
    % c.CIMData.RealizationData.InterpolationData.theta(ict) = ictinit * y(i);
    % c.CIMData.RealizationData.InterpolationData.sigma(ics) = icsinit * y(i);
    c.CIMData.compute();
    drawnow
end
