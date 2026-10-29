classdef ResultData < matlab.mixin.Copyable

    properties (SetObservable)
        Db
        Ds
        B
        BB
        C
        CC
    end

    properties (SetObservable) % full svd of Db
        X
        Sigma
        Y
    end

    properties (SetObservable)
        ew  % computed eigenvalues
        rev % computed right eigenvectors
        lev % computed left eigenvectors
        m   % the realization order of ew: RealizationSize.m, or under RealizationData.AutoRank the one RankRule chose; empty when the realization is cleared
        GapRatio = NaN  % sigma_m/sigma_{m+1} when the Gap rule chose m, below options.GapMin for a weak gap; NaN otherwise
    end

    properties (Dependent)
        Dbsize
        Dssize
    end

    methods(Access = protected)
      function cp = copyElement(obj)
          cp = feval(class(obj));
          cp.Db     = obj.Db;
          cp.Ds     = obj.Ds;
          cp.B      = obj.B;
          cp.BB     = obj.BB;
          cp.C      = obj.C;
          cp.CC     = obj.CC;
          cp.X      = obj.X;
          cp.Sigma  = obj.Sigma;
          cp.Y      = obj.Y;
          cp.ew     = obj.ew;
          cp.rev    = obj.rev;
          cp.lev    = obj.lev;
          cp.m      = obj.m;
          cp.GapRatio = obj.GapRatio;
      end

      function reattachListeners(~)
      end
   end

    methods (Static)
        function obj = loadobj(obj)
            if isstruct(obj)
                warning("Numerics:ResultData:loadobj", "A ResultData could not be loaded as an object and is returned as a struct.");
                return;
            end
            obj.reattachListeners();
        end
    end

    methods

        function obj = ResultData(Db,Ds,B,BB,C,CC,X,Sigma,Y,ew,rev,lev)
            arguments
                Db      = []
                Ds      = []
                B       = []
                BB      = []
                C       = []
                CC      = []
                X       = []
                Sigma   = []
                Y       = []
                ew      = []
                rev     = []
                lev     = []
            end
            obj.Db      = Db;
            obj.Ds      = Ds;
            obj.B       = B;
            obj.BB      = BB;
            obj.C       = C;
            obj.CC      = CC;
            obj.X       = X;
            obj.Sigma   = Sigma;
            obj.Y       = Y;
            obj.ew      = ew;
            obj.rev     = rev;
            obj.lev     = lev;
        end

        function value = get.Dbsize(obj)
            value = size(obj.Db);
        end

        function value = get.Dssize(obj)
            value = size(obj.Ds);
        end

        function H = getTransferFunction(obj, deriv)
            % Returns transfer function handle from computed eigenvalues/eigenvectors.
            % The returned function handle evaluates the transfer function at any point z.
            arguments
                obj
                deriv = 0
            end
            if isempty(obj.ew) || isempty(obj.rev) || isempty(obj.lev)
                error('ResultData:NoResults', 'No computed results available. Call CIM.compute() first.');
            end
            ew = obj.ew; lev = obj.lev; rev = obj.rev;
            H = @(z) Numerics.poresz(z, ew, lev, rev, deriv);
        end

    end

end
