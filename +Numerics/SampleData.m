classdef SampleData < handle

    properties
        Ql      (:,:,:) double = missing
        Qr      (:,:,:) double = missing
        Qlr     (:,:,:) double = missing
    end
    
    properties (SetObservable)
        ell     (1,1) double
        r       (1,1) double
        L       (:,:) double
        R       (:,:) double
        NLEVP
        Contour = missing
        loaded  = false
        auto    = false
    end
    
    methods

        function obj = SampleData(NLEVP,Contour,ell,r)
            arguments
                NLEVP
                Contour = missing
                ell = NLEVP.n
                r = NLEVP.n
            end
            obj.L = Numerics.SampleData.sampleMatrix(NLEVP.n,ell);
            obj.R = Numerics.SampleData.sampleMatrix(NLEVP.n,r);
            obj.NLEVP = NLEVP;
            obj.Contour = Contour;
            obj.ell = ell;
            obj.r = r;
            addlistener(obj,'ell','PostSet',@obj.LRdimchanged);
            addlistener(obj,'r','PostSet',@obj.LRdimchanged);
        end

        function sample(obj)
            if ismissing(obj.Contour)
                error("Contour data required to sample %s. Please set a contour and try again.",obj.NLEVP.name);
            end
            [obj.Ql,obj.Qr,obj.Qlr] = Numerics.samplequadrature(obj.NLEVP.T,obj.L,obj.R,obj.Contour.z);
            obj.loaded = true;
        end

        function LRdimchanged(obj,src,event)
            display(event);
            switch src.Name
                case 'ell'
                    
                case 'r'
            end
        end

    end

    methods (Static)

        function M = sampleMatrix(n,d)
            M = randn(n,d);
        end

    end

end

