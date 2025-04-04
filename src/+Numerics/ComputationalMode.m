classdef ComputationalMode
    % Enumeration of the available computational modes.
    % Hankel - Essentially Probed Eigenvalue Realization Algorithm (ERA)
    % SPLoewner - Hankel using probed generalized moments at a single shift
    % MPLoewner - Generic tangential Loewner interpolation
    enumeration
        Hankel, SPLoewner, MPLoewner
    end
end
