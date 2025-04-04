function [theta,sigma] = default(mode)
    import Numerics.ComputationalMode
    switch mode
        case ComputationalMode.Hankel
            theta = []; sigma = Inf;
        case ComputationalMode.SPLoewner
            theta = []; sigma = 0;
        case ComputationalMode.MPLoewner
            theta = []; sigma = [];
    end
end