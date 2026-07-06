function saveState(obj, filepath)
% SAVESTATE Write the full session state to a .mat file.
%
% Persists the complete state struct (see toStruct) -- operator, contour,
% sample data including cached quadrature, realization parameters, and
% computed results -- to FILEPATH (a .mat extension is enforced). A native
% function-handle operator and complex-valued samples/results round-trip
% losslessly. Reload with Numerics.CIM.loadState.
%
% See also Numerics.CIM.loadState, Numerics.CIM.toStruct.

    arguments
        obj
        filepath (1,1) string
    end

    [d, base, ~] = fileparts(filepath);
    matpath = fullfile(d, base + ".mat");

    state = obj.toStruct(); %#ok<NASGU>
    save(matpath, 'state', '-v7.3');
end
