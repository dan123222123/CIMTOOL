classdef RealizationData < handle
    
    properties (SetObservable)
        ComputationalMode 
        % make this an enum, listen and set from the main app
        % this might be useful here, and we may be able to save some
        % sampling overhead if the mode is right.
        theta   % left shifts
        sigma   % right shifts
        K       % number of moments to use for Hankel/SPLoewner
        m       % number of eigenvalues to search for inside the contour
    end

    methods

    end

end

