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
            H = @(z) Numerics.poresz(z, obj.ew, obj.lev, obj.rev, deriv);
        end

    end

end
