classdef Sampling < handle

    properties
        L       (:,:) double
        R       (:,:) double
        Ql          (:,:,:) double
        Qr          (:,:,:) double
        Qlr         (:,:,:) double
    end
    
    properties (SetObservable)
        n       (1,1) double
        ell     (1,1) double
        r       (1,1) double
        ComputationalMode 
        % make this an enum, listen and set from the main app
        % this might be useful here, and we may be able to save some
        % sampling overhead if the mode is right.
    end
    
    methods

        function obj = Sampling(n,ell,r)
            obj.L = sample(n,ell);
            obj.R = sample(n,r);
            obj.n = n;
            obj.ell = ell;
            obj.r = r;
        end

    end

    methods (Static)

        function M = sample(n,d)
            M = randn(n,d);
        end

    end

end

