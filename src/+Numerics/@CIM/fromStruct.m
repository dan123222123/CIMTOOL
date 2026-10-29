function obj = fromStruct(s)
% FROMSTRUCT Greedily reconstruct a Numerics.CIM from a toStruct struct.
%
% Loading is deliberately tolerant ("greedy"): every field is restored if
% present and valid, and any recoverable failure falls back to the relevant
% constructor default with a warning rather than aborting the whole load.
% A partially-populated struct (e.g. a JSON sidecar with setup only) yields a
% usable object with the missing pieces left at their defaults.
%
% See also Numerics.CIM.toStruct, Numerics.CIM.loadState.

    arguments
        s (1,1) struct
    end

    if isfield(s, 'version') && s.version ~= 1
        warning('Numerics:CIM:fromStruct:version', ...
            'State version %g differs from supported version 1; loading greedily.', s.version);
    end

    % ---- operator ----
    op = getfielddefault(s, 'operator', struct('provenance', 'none'));
    od = Numerics.OperatorData();
    try
        switch getfielddefault(op, 'provenance', 'none')
            case 'nlevp'
                name    = op.name;
                arglist = getfielddefault(op, 'arglist', []);
                if isnumeric(arglist) && ~isempty(arglist)
                    arglist = num2cell(arglist(:).');   % JSON decodes cells to arrays
                end
                % Regenerate T/coeffs via nlevp directly (loadNLEVPPACK expects a
                % comma-string arglist and pops a uialert on error -- unusable here).
                if isempty(arglist)
                    [coeffs, ~, T] = nlevp(name);
                else
                    [coeffs, ~, T] = nlevp(name, arglist{:});
                end
                od.name              = name;
                od.arglist           = arglist;
                od.coeffs            = coeffs;
                od.T                 = T;
                od.compute_reference = false;   % keep the saved refew below, don't recompute
                od.loaded            = true;
            case 'handle'
                if isfield(op, 'T') && isa(op.T, 'function_handle')
                    od.T = op.T;
                elseif isfield(op, 'Tstr')
                    od.T = str2func(op.Tstr);   % never errors on its own; probe below
                end
                if ~isempty(od.T)
                    od.T(0);                    % probe-eval: a broken handle throws here
                    od.loaded = true;
                end
        end
    catch ME
        warning('Numerics:CIM:fromStruct:operator', ...
            'Could not reconstruct operator (%s); leaving it unloaded.', ME.message);
        od = Numerics.OperatorData();
    end
    % operator metadata (greedy)
    od.sample_mode = toSampleMode(getfielddefault(op, 'sample_mode', []), od.sample_mode);
    if isfield(op, 'refew');            od.refew            = op.refew;            end
    if isfield(op, 'refev');            od.refev            = op.refev;            end
    if isfield(op, 'compute_reference'); od.compute_reference = logical(op.compute_reference); end

    % ---- contour ----
    c = Numerics.Contour.Circle();
    if isfield(s, 'contour')
        try
            c = contourFromStruct(s.contour);
        catch ME
            warning('Numerics:CIM:fromStruct:contour', ...
                'Could not reconstruct contour (%s); using default Circle.', ME.message);
        end
    end

    % ---- realization data ----
    R      = getfielddefault(s, 'realization', struct());
    cm     = toComputationalMode(getfielddefault(R, 'ComputationalMode', []), ...
                                 Numerics.ComputationalMode.Hankel);
    interp = Numerics.InterpolationData(getfielddefault(R, 'theta', []), ...
                                        getfielddefault(R, 'sigma', []));
    rsz    = getfielddefault(R, 'RealizationSize', struct());
    rsize  = Numerics.RealizationSize(getfielddefault(rsz, 'm',  0), ...
                                      getfielddefault(rsz, 'T1', 0), ...
                                      getfielddefault(rsz, 'T2', 0));
    % files saved before AutoRank carry a ranktol field instead, which no computation read; it is ignored
    rd     = Numerics.RealizationData(cm, interp, rsize, ...
                                      logical(getfielddefault(R, 'AutoRank', false)), ...
                                      toRankRule(getfielddefault(R, 'RankRule', []), Numerics.RankRule.Gap));

    % ---- sample data ----
    % Build with ell=r=0 to skip the constructor's random direction sampling,
    % then fill. Lf/Rf MUST be set before ell/r: the ell/r setters regenerate
    % or truncate the direction matrices whenever the count disagrees with the
    % current Lf/Rf width.
    Sd = getfielddefault(s, 'sample', struct());
    sd = Numerics.SampleData(od, c, 0, 0);
    if isfield(Sd, 'Lf'); sd.Lf = Sd.Lf; end
    if isfield(Sd, 'Rf'); sd.Rf = Sd.Rf; end
    if isfield(Sd, 'ell'); try, sd.ell = Sd.ell; catch, end; end
    if isfield(Sd, 'r');   try, sd.r   = Sd.r;   catch, end; end
    if isfield(Sd, 'Ql');            sd.Ql            = Sd.Ql;            end
    if isfield(Sd, 'Qr');            sd.Qr            = Sd.Qr;            end
    if isfield(Sd, 'Qlr');           sd.Qlr           = Sd.Qlr;           end
    if isfield(Sd, 'show_progress'); sd.show_progress = logical(Sd.show_progress); end

    % ---- assemble ----
    % Construct the default CIM (Hankel) FIRST, then swap in the restored
    % children. Building from the no-arg default means the constructor's
    % update_shifts() runs the harmless Hankel path -- it never touches the
    % restored MPLoewner/SPLoewner shifts, which pass through untouched.
    obj = Numerics.CIM();
    obj.auto_update_shifts = false;
    obj.auto_update_K      = false;
    obj.SampleData      = sd;
    obj.RealizationData = rd;
    obj.updateListeners([], []);   % rewire CIM listeners onto the new children

    % ---- result data ----
    RES = getfielddefault(s, 'result', struct());
    for f = ["Db","Ds","B","BB","C","CC","X","Sigma","Y","ew","rev","lev","m","GapRatio"]
        if isfield(RES, f)
            obj.ResultData.(f) = RES.(f);
        end
    end

    % ---- cim-level options ----
    C = getfielddefault(s, 'cim', struct());
    % merged over the defaults, so options added since the file was saved keep their defaults
    if isfield(C, 'options') && isstruct(C.options)
        opts = obj.options;
        for f = string(fieldnames(C.options))'
            opts.(f) = C.options.(f);
        end
        obj.options = opts;
    end

    % ---- restore loaded flags LAST (every setter above resets them) ----
    if isfield(Sd, 'loaded'); obj.SampleData.loaded      = logical(Sd.loaded); end
    if isfield(R,  'loaded'); obj.RealizationData.loaded = logical(R.loaded);   end

    % restore auto-update flags last, then derive DataDirtiness from loaded state
    if isfield(C, 'auto_update_shifts'); obj.auto_update_shifts = logical(C.auto_update_shifts); end
    if isfield(C, 'auto_update_K');      obj.auto_update_K      = logical(C.auto_update_K);      end
    obj.checkdirty([], []);
end

% ---------------------------------------------------------------------------

function v = getfielddefault(s, name, dflt)
    if isstruct(s) && isfield(s, name) && ~isempty(s.(name))
        v = s.(name);
    else
        v = dflt;
    end
end

function c = contourFromStruct(cs)
    switch cs.type
        case 'Circle'
            c = Numerics.Contour.Circle(cs.gamma, cs.rho, cs.N);
        case 'Ellipse'
            c = Numerics.Contour.Ellipse(cs.gamma, cs.alpha, cs.beta, cs.N);
        case 'CircularSegment'
            c = Numerics.Contour.CircularSegment(cs.gamma, cs.rho, ...
                    cs.theta(:).', cs.N(:).', string(cs.qr));
        case 'Quad'
            c = Numerics.Contour.Quad(cs.z(:).', cs.w(:).');
        otherwise
            warning('Numerics:CIM:fromStruct:unknownContour', ...
                'Unknown contour type "%s"; using default Circle.', cs.type);
            c = Numerics.Contour.Circle();
    end
end

function e = toComputationalMode(val, dflt)
    if isa(val, 'Numerics.ComputationalMode'); e = val; return; end
    if isempty(val); e = dflt; return; end
    switch char(val)
        case 'Hankel';    e = Numerics.ComputationalMode.Hankel;
        case 'SPLoewner'; e = Numerics.ComputationalMode.SPLoewner;
        case 'MPLoewner'; e = Numerics.ComputationalMode.MPLoewner;
        otherwise;        e = dflt;
    end
end

function e = toRankRule(val, dflt)
    if isa(val, 'Numerics.RankRule'); e = val; return; end
    if isempty(val); e = dflt; return; end
    switch char(val)
        case 'Tolerance'; e = Numerics.RankRule.Tolerance;
        case 'Gap';       e = Numerics.RankRule.Gap;
        otherwise;        e = dflt;
    end
end

function e = toSampleMode(val, dflt)
    if isa(val, 'Numerics.SampleMode'); e = val; return; end
    if isempty(val); e = dflt; return; end
    switch char(val)
        case 'Direct';  e = Numerics.SampleMode.Direct;
        case 'Inverse'; e = Numerics.SampleMode.Inverse;
        otherwise;      e = dflt;
    end
end
