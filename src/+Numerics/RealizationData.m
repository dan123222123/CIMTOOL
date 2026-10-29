classdef RealizationData < matlab.mixin.Copyable

    properties (SetObservable)
        ComputationalMode
        InterpolationData
        RealizationSize
        AutoRank (1,1) logical = false                              % choose m from Db by RankRule instead of RealizationSize.m
        RankRule (1,1) Numerics.RankRule = Numerics.RankRule.Gap   % how computeRealization chooses m under AutoRank; kept while AutoRank is off
        %auto_update_realization_size = true
        loaded = false
    end

    properties (Dependent)
        m
        K
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = feval(class(obj));
            cp.ComputationalMode = obj.ComputationalMode;
            cp.InterpolationData = obj.InterpolationData;
            cp.RealizationSize = obj.RealizationSize;
            cp.AutoRank = obj.AutoRank;
            cp.RankRule = obj.RankRule;
            %cp.auto_update_realization_size = obj.auto_update_realization_size;
            cp.loaded = obj.loaded;
        end

        function reattachListeners(obj)
            obj.updateListeners();
        end
    end

    methods (Static)
        function obj = loadobj(obj)
            if isstruct(obj)
                warning("Numerics:RealizationData:loadobj", "A RealizationData could not be loaded as an object and is returned as a struct.");
                return;
            end
            obj.reattachListeners();
        end
    end

    methods

        function obj = RealizationData(ComputationalMode,InterpolationData,RealizationSize,AutoRank,RankRule)
            arguments
                ComputationalMode = Numerics.ComputationalMode.Hankel
                InterpolationData = []
                RealizationSize = []
                AutoRank = false
                RankRule = Numerics.RankRule.Gap
            end
            obj.ComputationalMode = ComputationalMode;
            if isempty(InterpolationData)
                obj.defaultInterpolationData();
            else
                obj.InterpolationData = InterpolationData;
            end
            m = max(length(obj.InterpolationData.theta),length(obj.InterpolationData.sigma));
            if isempty(RealizationSize)
                obj.RealizationSize = Numerics.RealizationSize(m,m,m);
            else
                obj.RealizationSize = RealizationSize;
            end
            obj.AutoRank = AutoRank;
            obj.RankRule = RankRule;
            obj.updateListeners();
            obj.RealizationDataChanged();
        end

        function value = get.K(obj)
            value = max(obj.RealizationSize.T1,obj.RealizationSize.T2);
        end

        function set.K(obj,value)
            obj.RealizationSize = Numerics.RealizationSize(obj.RealizationSize.m,value);
        end

        function value = get.m(obj)
            value = obj.RealizationSize.m;
        end

        function set.m(obj,value)
            obj.RealizationSize = Numerics.RealizationSize(value,obj.RealizationSize.T1,obj.RealizationSize.T2);
        end

        function set.ComputationalMode(obj,value)
            obj.ComputationalMode = value;
            obj.loaded = false;
        end

        function set.InterpolationData(obj,value)
            obj.InterpolationData = value;
            obj.InterpolationDataChanged([],[]);
        end

        function set.AutoRank(obj,value)
            obj.AutoRank = value;
            obj.loaded = false;   % the CIM realizes again; the samples stay
        end

        function set.RankRule(obj,value)
            obj.RankRule = value;
            if obj.AutoRank; obj.loaded = false; end   % a rule kept while AutoRank is off changes nothing
        end

        function defaultInterpolationData(obj)
            switch obj.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    theta = []; sigma = Inf;
                case Numerics.ComputationalMode.SPLoewner
                    theta = []; sigma = 0;
                case Numerics.ComputationalMode.MPLoewner
                    theta = []; sigma = [];
            end
            obj.InterpolationData = Numerics.InterpolationData(theta,sigma);
        end

        function [theta,sigma] = getThetaSigma(obj,T1,T2)
            arguments
                obj
                T1 = length(obj.InterpolationData.theta)
                T2 = length(obj.InterpolationData.sigma)
            end
            theta = obj.InterpolationData.theta;
            sigma = obj.InterpolationData.sigma;
            if obj.ComputationalMode == Numerics.ComputationalMode.MPLoewner
                theta = theta(1:min(T1,length(theta))); sigma = sigma(1:min(T2,length(sigma)));
            end
        end

        function updateListeners(obj)
            addlistener(obj,'RealizationSize','PostSet',@obj.RealizationDataChanged);
        end

        function RealizationDataChanged(obj,~,~)
            obj.loaded = false;
        end

        function InterpolationDataChanged(obj,~,~)
            obj.RealizationDataChanged([],[]);
        end

    end

end
