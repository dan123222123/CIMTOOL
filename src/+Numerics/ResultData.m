classdef ResultData < matlab.mixin.Copyable

    properties (SetObservable)
        Db
        Ds
        BB
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
          cp = eval(class(obj));
          cp.Db     = obj.Db;
          cp.Ds     = obj.Ds;
          cp.BB     = obj.BB;
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

        function obj = ResultData(Db,Ds,BB,CC,X,Sigma,Y,ew,rev,lev)
            arguments
                Db      = []
                Ds      = []
                BB      = []
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
            obj.BB      = BB;
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

        function [Lambda,V,W] = rtfm(obj,m,abstol)
            arguments
                obj
                m = Inf
                abstol = NaN
            end
            if m == length(obj.ew)
                Lambda = diag(obj.ew); V = obj.rev; W = obj.lev;
            else % need to do realization for m
                if isnan(abstol)
                    tol = max(size(obj.Sigma))*eps(obj.Sigma(1,1));
                else
                    tol = abstol;
                end
                r = sum(diag(obj.Sigma)>=tol);
                if r < m
                    error("Db has numerical rank %d < %d. Cannot recover TF!",r,m);
                end
                X=obj.X(:,1:m); Sigma=obj.Sigma(1:m,1:m); Y=obj.Y(:,1:m);
                [S,Lambda] = eig(X'*obj.Ds*Y,Sigma);
                Lambda = diag(Lambda); V = obj.CC*Y*(Sigma\S); W = S\(X'*obj.BB);
            end
        end

    end

end
