c = CIMTOOL();

% cunky due to method of setting defaults in GUI code
% GUI code will be modified to set defaults based on those present in the
% CIM object...
c.CIMData.SampleData.NLEVP.loadNLEVPpack('plasma_drift');
c.ParameterPanel.ContourTab.ContourTypeButtonGroup.SelectedObject = c.ParameterPanel.ContourTab.EllipseButton;
c.ParameterPanel.ContourTab.ContourTypeButtonGroupSelectionChanged(missing);

% changing contour parameters
c.CIMData.SampleData.Contour.gamma = 0.3i;
c.CIMData.SampleData.Contour.alpha = 3;
c.CIMData.SampleData.Contour.beta = 0.4;
c.CIMData.SampleData.Contour.N = 256;

% changing the method parameters
c.CIMData.SampleData.ell = 20; c.CIMData.SampleData.r = 20;
c.CIMData.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
c.CIMData.RealizationData.m = floor(length(nlevp.refew(c.CIMData.SampleData.Contour.inside(nlevp.refew)))/2);
c.CIMData.RealizationData.K = 2*c.CIMData.RealizationData.m;

% note that the corresponding GUI components are not yet updated -- need to
% add the "other direction" of communication so that the GUI components are
% updated when CIM is modified programatically

c.CIMData.compute();