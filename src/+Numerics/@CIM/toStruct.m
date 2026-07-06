function s = toStruct(obj)
% TOSTRUCT Serialize a Numerics.CIM into a plain nested struct.
%
% The returned struct captures the full session state -- operator, contour,
% sample data (including cached quadrature), realization parameters, and
% computed results -- so that Numerics.CIM.fromStruct can reconstruct an
% equivalent object. saveState writes this struct verbatim to the .mat file
% and (after pruning) to the .json sidecar.
%
% See also Numerics.CIM.fromStruct, Numerics.CIM.saveState.

    s = struct();
    s.version = 1;

    % --- operator ---
    od = obj.SampleData.OperatorData;
    op = struct();
    if ~isempty(od.name)
        % NLEVP problem: persist provenance so T/coeffs regenerate on load
        op.provenance = 'nlevp';
        op.name       = char(od.name);
        op.arglist    = od.arglist;          % cell of doubles, or []
    elseif ~isempty(od.T)
        % Raw function handle: keep the native handle (.mat) and its text form
        op.provenance = 'handle';
        op.T          = od.T;                 % native handle -- .mat only
        op.Tstr       = func2str(od.T);       % text form -- inspection / .json
    else
        op.provenance = 'none';
    end
    op.sample_mode       = char(od.sample_mode);
    op.compute_reference = od.compute_reference;
    op.refew             = od.refew;
    op.refev             = od.refev;
    op.coeffs            = od.coeffs;
    s.operator = op;

    % --- contour (generating parameters; nodes/weights regenerate) ---
    s.contour = contourToStruct(obj.SampleData.Contour);

    % --- sample data ---
    sd = obj.SampleData;
    S = struct();
    S.ell           = sd.ell;
    S.r             = sd.r;
    S.Lf            = sd.Lf;
    S.Rf            = sd.Rf;
    S.Ql            = sd.Ql;
    S.Qr            = sd.Qr;
    S.Qlr           = sd.Qlr;
    S.show_progress = sd.show_progress;
    S.loaded        = sd.loaded;
    s.sample = S;

    % --- realization data ---
    rd = obj.RealizationData;
    R = struct();
    R.ComputationalMode = char(rd.ComputationalMode);
    R.theta             = rd.InterpolationData.theta;
    R.sigma             = rd.InterpolationData.sigma;
    R.RealizationSize   = struct('m',  rd.RealizationSize.m, ...
                                 'T1', rd.RealizationSize.T1, ...
                                 'T2', rd.RealizationSize.T2);
    R.ranktol           = rd.ranktol;
    R.loaded            = rd.loaded;
    s.realization = R;

    % --- result data ---
    rs = obj.ResultData;
    RES = struct();
    for f = ["Db","Ds","B","BB","C","CC","X","Sigma","Y","ew","rev","lev"]
        RES.(f) = rs.(f);
    end
    s.result = RES;

    % --- cim-level ---
    C = struct();
    C.auto_update_shifts = obj.auto_update_shifts;
    C.auto_update_K      = obj.auto_update_K;
    C.options            = obj.options;
    s.cim = C;
end

function cs = contourToStruct(c)
% Persist a contour by its generating parameters (z/w regenerate from these).
% Uses isa (not class) so a Visual.Contour.* subclass serializes identically.
    cs = struct();
    if isa(c, 'Numerics.Contour.CircularSegment')
        cs.type  = 'CircularSegment';
        cs.gamma = c.gamma; cs.rho = c.rho; cs.theta = c.theta;
        cs.N     = c.N;     cs.qr  = char(c.qr);
    elseif isa(c, 'Numerics.Contour.Ellipse')
        cs.type  = 'Ellipse';
        cs.gamma = c.gamma; cs.alpha = c.alpha; cs.beta = c.beta; cs.N = c.N;
    elseif isa(c, 'Numerics.Contour.Circle')
        cs.type  = 'Circle';
        cs.gamma = c.gamma; cs.rho = c.rho; cs.N = c.N;
    else
        % Generic Quad or unrecognized subclass: persist raw nodes/weights.
        cs.type = 'Quad';
        cs.z = c.z; cs.w = c.w;
    end
end
