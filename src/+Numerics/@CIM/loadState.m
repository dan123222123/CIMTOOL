function obj = loadState(filepath)
% LOADSTATE Reconstruct a Numerics.CIM from a .mat file written by saveState.
%
% Reconstruction is greedy: missing or invalid fields fall back to defaults.
% See Numerics.CIM.fromStruct.
%
% See also Numerics.CIM.saveState, Numerics.CIM.fromStruct.

    arguments
        filepath (1,1) string
    end

    [~, ~, ext] = fileparts(filepath);
    if ~strcmpi(ext, ".mat")
        error('Numerics:CIM:loadState:ext', ...
            'Unsupported file type "%s" (expected .mat).', ext);
    end

    L = load(filepath);
    if ~isfield(L, 'state')
        error('Numerics:CIM:loadState:badFile', ...
            '%s is not a CIMTOOL session file (no "state" variable).', filepath);
    end

    obj = Numerics.CIM.fromStruct(L.state);
end
