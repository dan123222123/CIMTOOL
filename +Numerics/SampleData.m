classdef SampleData < handle

    properties
        Ql      (:,:,:) double = missing
        Qr      (:,:,:) double = missing
        Qlr     (:,:,:) double = missing
    end
    
    properties (SetObservable)
        n       (1,1) double
        ell     (1,1) double
        r       (1,1) double
        L       (:,:) double
        R       (:,:) double
        loaded = false
    end
    
    methods

        function obj = SampleData(n,ell,r)
            obj.L = Numerics.SampleData.sampleMatrix(n,ell);
            obj.R = Numerics.SampleData.sampleMatrix(n,r);
            obj.n = n;
            obj.ell = ell;
            obj.r = r;
        end

    end

    methods (Static)

        function M = sampleMatrix(n,d)
            M = randn(n,d);
        end

    end

end

