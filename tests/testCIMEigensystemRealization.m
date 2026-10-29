% setup
% I reckon these test problems can be defined in their own files that can
% be imported here (and elsewhere?!?) when desired!

import Visual.*;
rng(0);
n = 6; m = n; p = n; ewref = -1:-1:-n;
A = diag(ewref); B = randn(n,m); C = randn(p,n);
H = @(z) C*((z*eye(size(A)) - A) \ B);
rtf = OperatorData(H); rtf.refew = ewref;
rtf.sample_mode = Numerics.SampleMode.Direct;
%
contour = Contour.Ellipse(-(n+1)/2,((n+1)/2),0.5,8);
CIMStruct = CIM(rtf,contour);
CIMStruct.RealizationData.RealizationSize.m = length(ewref);
c = CIMTOOL(CIMStruct);

tol = sqrt(eps);

% might be a cleaner way to do this with a function-based unit test script,
% but this works in a pinch...

%% non-sketched Hankel -- TODO
assert(true)

%% sketched Hankel -- No blocked
CIMStruct.compute(); ngmd = CIMStruct.matchingDistance();
fprintf("Optimal Matching Distance: %e vs TOL: %e\n",ngmd,tol);
assert(ngmd < tol);

%% sketched Hankel -- 3x3 Moments, 2x2 Blocked Hankel
CIMStruct.SampleData.ell = 3; CIMStruct.SampleData.r = 3;
CIMStruct.RealizationData.RealizationSize = Numerics.RealizationSize(length(ewref),2,2);
CIMStruct.compute(); ngmd = CIMStruct.matchingDistance();
fprintf("Optimal Matching Distance: %e vs TOL: %e\n",ngmd,tol);
assert(ngmd < tol);

%% sketched Hankel -- 2x2 Moments, 3x3 Blocked Hankel
CIMStruct.SampleData.ell = 2; CIMStruct.SampleData.r = 2;
CIMStruct.RealizationData.RealizationSize = Numerics.RealizationSize(length(ewref),3,3);
CIMStruct.compute(); ngmd = CIMStruct.matchingDistance();
fprintf("Optimal Matching Distance: %e vs TOL: %e\n",ngmd,tol);
assert(ngmd < tol);

%% sketched Hankel -- 1x1 Moments, 6x6 Blocked Hankel
CIMStruct.SampleData.ell = 1; CIMStruct.SampleData.r = 1;
CIMStruct.RealizationData.RealizationSize = Numerics.RealizationSize(length(ewref),6,6);
CIMStruct.compute(); ngmd = CIMStruct.matchingDistance();
fprintf("#Quad: %d -- Optimal Matching Distance: %e vs TOL: %e\n",contour.N,ngmd,sqrt(tol));
assert(~(ngmd < sqrt(tol)));
%
contour.N = 128; CIMStruct.compute(); ngmd = CIMStruct.matchingDistance();
fprintf("#Quad: %d -- Optimal Matching Distance: %e vs TOL: %e\n",contour.N,ngmd,sqrt(tol));
assert(ngmd < sqrt(tol));

%% the panels follow a replaced operator (they listen on the operator object)
if exist('nlevp','file')
    op2 = Visual.OperatorData([],'acoustic_wave_1d');
    lastwarn('');
    CIMStruct.SampleData.OperatorData = op2; drawnow;   % n = 10 after computed n = 6 results
    assert(isempty(lastwarn), "replacing the operator after a compute must not error in a listener: %s", lastwarn);
    assert(c.LeftPanel.ProblemName.Value == "acoustic_wave_1d" && c.LeftPanel.ProblemSize.Value == op2.n, "LeftPanel must show the new operator");
    assert(startsWith(strtrim(string(c.ParameterPanel.NLEVPTab.NLEVPHelpTextArea.Value{1})),"ACOUSTIC_WAVE_1D"), "NLEVPTab must show the new operator's help");
    op2.refew = [-2; -3]; drawnow;   % both inside the ellipse
    assert(contains(string(c.PlotPanel.ResultsTable.ColumnName{1}), "Inside Contour 2"), "PlotPanel must follow the new operator's reference eigenvalues");
    op2.loaded = false; drawnow;
    assert(c.LeftPanel.ProblemName.Value == "Not Loaded", "LeftPanel must follow the new operator's loaded flag");
end

%% the panels follow replaced contours, SampleData and RealizationData
pp = c.ParameterPanel; mc = @() pp.MethodTab.MethodComponent;
oldct = CIMStruct.SampleData.Contour;
CIMStruct.SampleData.Contour = Visual.Contour.Circle(-3, 4, 48); drawnow;
assert(isa(pp.ContourTab.ContourComponent, 'GUI.Parameter.Contour.CircleComponent') && c.LeftPanel.NumQuadNodes.Value == "48", "the contour tab and left panel must show the new contour");
oldct.N = 16; drawnow;
assert(c.LeftPanel.NumQuadNodes.Value == "48", "a replaced contour must no longer reach the GUI");
oldsd = CIMStruct.SampleData;
CIMStruct.SampleData = Visual.SampleData(rtf, Visual.Contour.Ellipse(-3, 4, 1, 40), 3, 2); drawnow;
assert(isa(pp.ContourTab.ContourComponent, 'GUI.Parameter.Contour.EllipseComponent') && c.LeftPanel.NumQuadNodes.Value == "40" ...
    && mc().LeftProbingSizeEditField.Value == 3 && mc().RightProbingSizeEditField.Value == 2, "the panels must show the new SampleData");
oldsd.ell = 5; CIMStruct.SampleData.r = 4; drawnow;
assert(mc().LeftProbingSizeEditField.Value == 3 && mc().RightProbingSizeEditField.Value == 4, "only the current SampleData must reach the GUI");
oldrd = CIMStruct.RealizationData;
CIMStruct.RealizationData = Visual.RealizationData(Numerics.ComputationalMode.MPLoewner, [], Numerics.RealizationSize(5, 9, 9)); drawnow;
assert(pp.MethodTab.MPLoewnerButton.Value && pp.MethodTab.EigSearchEditField.Value == 5 && mc().MaxMomentsEditField.Value == 9 ...
    && height(pp.ShiftsTab.ShiftsTable.Data) == 9, "the panels must show the new RealizationData");
oldrd.RealizationSize = Numerics.RealizationSize(2, 3, 3); drawnow;
assert(pp.MethodTab.EigSearchEditField.Value == 5, "a replaced RealizationData must no longer reach the GUI");

% %% SPLoewner -- No blocked
% CIMStruct.setComputationalMode(Numerics.ComputationalMode.SPLoewner)
% CIMStruct.compute(); ngmd = CIMStruct.matchingDistance();
% assert(ngmd < tol,fprintf("Optimal Matching Distance: %e vs TOL: %e\n",ngmd,tol));

%% a contour type without an editor leaves the contour tab empty, without errors
CIMStruct.setComputationalMode(Numerics.ComputationalMode.Hankel);   % a plain Quad has no interleaved MPLoewner shifts
lastwarn('');
CIMStruct.SampleData.Contour = Visual.Contour.Quad(contour.z, contour.w); drawnow;
c.updateFontSize(1); c.updateFontSize(-1); drawnow;
assert(isempty(pp.ContourTab.ContourComponent) && isempty(lastwarn), "a Quad contour must leave the contour tab empty without warnings: %s", lastwarn);
CIMStruct.SampleData.Contour = Visual.Contour.Circle(-3, 4, 48); drawnow;
assert(isa(pp.ContourTab.ContourComponent, 'GUI.Parameter.Contour.CircleComponent'), "the contour tab must recover with an editable contour");

%% the left panel shows the operator's reference computation, and its x cancels it
if exist('nlevp','file')
    lp = c.LeftPanel; op4 = Visual.OperatorData(); op4.ReferenceWait = 0; op4.MaxReferenceSize = Inf;
    CIMStruct.SampleData.OperatorData = op4; drawnow;
    assert(isequal(lp.GridLayout.RowHeight{3}, 0), "an operator without a reference computation must collapse the status row");
    op4.loadNLEVPPACK('acoustic_wave_1d', "1000,1"); drawnow;   % tens of seconds on the background pool
    assert(lp.ReferenceStatusLabel.Text == "Reference eigenvalues: computing..." && lp.ReferenceCancelButton.Visible == "on", ...
        "a computing reference must show its status and x");
    press(matlab.uitest.TestCase.forInteractiveUse, lp.ReferenceCancelButton);
    assert(op4.ReferenceStatus == "cancelled" && lp.ReferenceStatusLabel.Text == "Reference eigenvalues: cancelled" ...
        && lp.ReferenceCancelButton.Visible == "off", "x must cancel the reference computation");
    op4.loadNLEVPPACK('acoustic_wave_1d'); op4.waitReference(); drawnow;
    assert(lp.ReferenceStatusLabel.Text == "Reference eigenvalues: done" && isscalar(findall(c.PlotPanel.MainPlotAxes, 'Tag', 'reference_eigenvalues')), ...
        "a finished reference must be shown and drawn");
    CIMStruct.SampleData.OperatorData = rtf; drawnow;
end

%% a CIM opened in MPLoewner, already computed, shows its own state
rtf3 = OperatorData(H); rtf3.sample_mode = Numerics.SampleMode.Direct;
cmp = CIM(rtf3, Contour.Circle(-3.5, 4, 64)); cmp.SampleData.show_progress = false; cmp.options.Verbose = false;
cmp.setComputationalMode(Numerics.ComputationalMode.MPLoewner, Numerics.RealizationSize(n, n, n)); cmp.compute();
c3 = CIMTOOL(cmp); drawnow;
assert(c3.ParameterPanel.MethodTab.MethodComponent.MaxMomentsEditFieldLabel.Text == "# Left/Right Interpolants" ...
    && all(c3.ParameterPanel.ShiftsTab.ShiftsTable.ColumnEditable) && c3.LeftPanel.DataMatrixSize.Value == n, ...
    "a GUI opened on a computed MPLoewner CIM must show its mode, editable shifts and data matrix size");
delete(c3);
