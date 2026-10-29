classdef CIM < matlab.mixin.Copyable
    properties (Access = public, SetObservable)
        SampleData          Numerics.SampleData
        RealizationData     Numerics.RealizationData
        ResultData          Numerics.ResultData
    end
    properties (SetObservable)
        DataDirtiness = 2           % >1 => resample, >0 => perform realization, =0 => no action needed
        auto_update_shifts = true; % update shifts in response to contour changes, realization parameters, etc.
        auto_update_K = true;       % updake K in response to changes in ComputationalMode -- approximately maintains equivalent data matrix size between Hankel/MPLoewner, etc.
        % AbsTol/RelTol: rank tolerance of the base data matrix, absolute or relative to its largest singular value (the larger applies; both NaN => max(size)*eps(sigma_1))
        % GapMin: a largest gap sigma_m/sigma_{m+1} below it is weak; the Gap rank rule still realizes at it, and warns under Verbose
        % EmptyTol: under AutoRank, a contour whose moment level (Numerics.momentlevel) is below it encloses no eigenvalue, and m = 0
        options = struct("PadStrategy","cyclical","AbsTol",NaN,"RelTol",NaN,"GapMin",1e3,"EmptyTol",1e-10,"Verbose",true);
    end
    properties (Access = private, Transient)
        % listeners on the current SampleData/Contour/RealizationData, deleted when those are replaced
        SampleDataListeners         = event.proplistener.empty
        ContourListeners            = event.proplistener.empty
        RealizationDataListeners    = event.proplistener.empty
    end
    methods(Access = protected)
        function cp = copyElement(obj)
            cp = feval(class(obj));
            % with the auto updates off, the copied sub-objects keep their shifts and loaded flags
            cp.auto_update_shifts = false; cp.auto_update_K = false;
            % options before RealizationData, since an options change marks the realization stale
            cp.options = obj.options;
            % assigning SampleData/RealizationData re-wires cp's listeners
            cp.SampleData = copy(obj.SampleData);
            cp.RealizationData = copy(obj.RealizationData);
            cp.ResultData = copy(obj.ResultData);
            % replacing the parts marked cp's realization stale; the copied results match the copied samples
            cp.RealizationData.loaded = obj.RealizationData.loaded;
            cp.auto_update_shifts = obj.auto_update_shifts;
            cp.auto_update_K = obj.auto_update_K;
            cp.checkdirty([],[]);
        end

        function reattachListeners(obj)
            % without update_shifts or checkdirty
            obj.addSelfListeners();
            obj.wireSampleData();
            obj.wireContour();
            obj.wireRealizationData();
        end
    end
    methods (Static)
        function obj = loadobj(obj)
            % Listeners are not saved, a CIM loaded from a MAT file installs them again
            if isstruct(obj)
                warning("Numerics:CIM:loadobj", "A CIM could not be loaded as an object and is returned as a struct.");
                return;
            end
            obj.reattachListeners();
        end
    end
    methods (Access = private)
        function addSelfListeners(obj)
            % mark the realization stale before a part is replaced
            addlistener(obj,'SampleData','PreSet',@obj.markRealizationStale);
            addlistener(obj,'ResultData','PreSet',@obj.markRealizationStale);
            addlistener(obj,'SampleData','PostSet',@obj.updateSampleDataListeners);
            addlistener(obj,'RealizationData','PostSet',@obj.updateRealizationDataListeners);
            addlistener(obj,'ResultData','PostSet',@obj.markRealizationStale);
            addlistener(obj,'options','PostSet',@obj.markRealizationStale);
        end

        % The listeners on parts hold the CIM weakly (Numerics.weakListener), so a part that outlives
        % the CIM (shared with another CIM or held by a script) does not keep it alive.
        function wireContour(obj)
            delete(obj.ContourListeners(isvalid(obj.ContourListeners)));
            obj.ContourListeners = Numerics.weakListener(obj.SampleData.Contour,'z',obj,@(o,s,e) o.update_shifts(s,e));
        end

        function wireRealizationData(obj)
            delete(obj.RealizationDataListeners(isvalid(obj.RealizationDataListeners)));
            rd = obj.RealizationData;
            obj.RealizationDataListeners = [
                Numerics.weakListener(rd,'loaded',obj,@(o,s,e) o.checkdirty(s,e))
                Numerics.weakListener(rd,'ComputationalMode',obj,@(o,s,e) o.update_shifts(s,e))
                Numerics.weakListener(rd,'RealizationSize',obj,@(o,s,e) o.update_shifts(s,e))
            ];
        end

        function wireSampleData(obj)
            delete(obj.SampleDataListeners(isvalid(obj.SampleDataListeners)));
            sd = obj.SampleData;
            obj.SampleDataListeners = [
                Numerics.weakListener(sd,'loaded',obj,@(o,s,e) o.samplesChanged(s,e))
                Numerics.weakListener(sd,'Contour',obj,@(o,s,e) o.updateContourListeners(s,e))
                Numerics.weakListener(sd,'ell',obj,@(o,s,e) o.markRealizationStale(s,e))
                Numerics.weakListener(sd,'r',obj,@(o,s,e) o.markRealizationStale(s,e))
            ];
        end
    end
    methods
        function delete(obj)
            % remove the listeners left on parts that outlive the CIM
            listeners = [obj.SampleDataListeners; obj.ContourListeners; obj.RealizationDataListeners];
            delete(listeners(isvalid(listeners)));
        end
        function obj = CIM(OperatorData,Contour,RealizationData)
            arguments
                OperatorData (1,1) {mustBeA(OperatorData,'Numerics.OperatorData')} = Numerics.OperatorData()
                Contour {mustBeScalarOrEmpty, mustBeA(Contour,'Numerics.Contour.Quad')} = Numerics.Contour.Quad.empty   % none until the user chooses one
                RealizationData (1,1) {mustBeA(RealizationData,'Numerics.RealizationData')} = Numerics.RealizationData()
            end
            obj.SampleData = Numerics.SampleData(OperatorData,Contour);
            obj.RealizationData = RealizationData;
            obj.ResultData = Numerics.ResultData();
            obj.addSelfListeners();
            obj.updateListeners([],[]);
        end
        function setComputationalMode(obj,cm,RealizationSize)
        % Set the computational mode of the CIM object, and optionally its realization size.
        %
        % Arguments:
        %   cm: Numerics.ComputationalMode.{Hankel,SPLoewner,MPLoewner}.
        %   RealizationSize: Numerics.RealizationSize applied together with cm, so that the shifts are computed once, for both. auto_update_K does not apply then.
            arguments
                obj
                cm
                RealizationSize Numerics.RealizationSize = Numerics.RealizationSize.empty
            end
            if ~isempty(RealizationSize)
                aus = obj.auto_update_shifts;
                obj.auto_update_shifts = false;
                obj.RealizationData.ComputationalMode = cm;
                obj.RealizationData.RealizationSize = RealizationSize;
                obj.auto_update_shifts = aus;
                obj.default_shifts();
                return;
            end
            if obj.RealizationData.ComputationalMode == cm
                return;
            end
            switch obj.RealizationData.ComputationalMode
                case {Numerics.ComputationalMode.Hankel,Numerics.ComputationalMode.SPLoewner}
                    odms = min(obj.SampleData.ell,obj.SampleData.r)*obj.RealizationData.K;
                case Numerics.ComputationalMode.MPLoewner
                    odms = obj.RealizationData.K;
            end
            obj.RealizationData.ComputationalMode = cm;
            obj.default_shifts();
            if obj.auto_update_K && min(obj.SampleData.ell,obj.SampleData.r) ~= 0
                switch cm
                    case {Numerics.ComputationalMode.Hankel,Numerics.ComputationalMode.SPLoewner}
                        K = ceil(odms/min(obj.SampleData.ell,obj.SampleData.r));
                    case Numerics.ComputationalMode.MPLoewner
                        K = odms;
                end
                obj.RealizationData.RealizationSize = Numerics.RealizationSize(obj.RealizationData.RealizationSize.m,K,K);
            end
        end
        function default_shifts(obj)
        % Sets default shifts using the current ComputationalMode and Contour data.
            if obj.noContourForShifts()
                return;
            end
            switch obj.RealizationData.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    obj.RealizationData.InterpolationData = Numerics.InterpolationData(NaN,Inf);
                case Numerics.ComputationalMode.SPLoewner
                    obj.RealizationData.InterpolationData = Numerics.InterpolationData(NaN,obj.SampleData.Contour.FindShift());
                case Numerics.ComputationalMode.MPLoewner
                    obj.contour_interlevedshifts();
            end
        end
        function compute(obj)
        % Compute SampleData (if necessary), and perform realization.
            obj.SampleData.compute();
            obj.computeRealization();
        end
        function [Db,Ds] = getFullDataMatrices(obj)
        % Returns the full data matrices Db and Ds, sampling and building them if necessary, without realizing.
            if obj.DataDirtiness > 0
                obj.SampleData.compute();
                obj.computeDataMatrices();
            end
            Db = obj.ResultData.Db;
            Ds = obj.ResultData.Ds;
        end
        function level = contourMomentLevel(obj)
        % Numerics.momentlevel of the two-sided samples: near eps when the contour encloses no eigenvalue, of order one otherwise.
            [~,~,Qlr] = obj.SampleData.activeSamples();
            level = Numerics.momentlevel(Qlr,obj.SampleData.Contour.z,obj.SampleData.Contour.w);
        end
        function [V, D, W] = eigs(obj)
        % Computes the eigenvalues and right/left eigenvectors -- mimics the interface of MATLAB's eig function.
            obj.compute();
            [~,ewidx] = sort(abs(obj.ResultData.ew));
            if nargout <= 1
                V = obj.ResultData.ew(ewidx);
            elseif nargout >= 2
                % reshape, not ', so an empty realization gives 1x0 norms
                V = obj.ResultData.rev(:,ewidx); V = V ./ reshape(sqrt(diag(V'*V)),1,[]);
                D = diag(obj.ResultData.ew(ewidx));
                W = obj.ResultData.lev(ewidx,:)'; W = W ./ reshape(sqrt(diag(W'*W)),1,[]);
            end
        end
        function [H,Lambda,W,V] = tf(obj,m,abstol)
        % Computes the transfer function of state dimension m from the sampling/realization data.
        % m defaults to the m of the realization (RealizationSize.m, or under RealizationData.AutoRank the one RankRule chose).
            arguments
                obj
                m = []
                abstol = NaN
            end
            cp = copy(obj); cp.compute();
            if isempty(m); m = cp.ResultData.m; end
            [Lambda,V,W] = Numerics.tf_dbsvd(m, ...
                cp.ResultData.X, ...
                cp.ResultData.Sigma, ...
                cp.ResultData.Y, ...
                cp.ResultData.Ds, ...
                cp.ResultData.B, ...
                cp.ResultData.C, ...
                abstol ...
                );

            H = @(z) V*((z*eye(size(Lambda))-Lambda)\W);
        end
    end
    methods (Access = public)
        interlevedshifts(obj);
        computeDataMatrices(obj);
        computeRealization(obj);
        refineQuadrature(obj);
        [nmd,pairs] = matchingDistance(obj);
        s = toStruct(obj);
        saveState(obj,filepath);
    end
    methods (Static)
        obj = fromStruct(s);
        obj = loadState(filepath);
    end
    methods (Access = protected)
        buildDataMatrices(obj);

        function clearRealization(obj)
            % the eigenpairs, their m and gap; the SVD of Db stays with Db
            rd = obj.ResultData;
            rd.ew = []; rd.rev = []; rd.lev = []; rd.m = []; rd.GapRatio = NaN;
            obj.RealizationData.loaded = false;
        end

        function updateContourListeners(obj,~,~)
            obj.wireContour();
            obj.update_shifts([],[]);
        end

        function updateRealizationDataListeners(obj,~,~)
            obj.wireRealizationData();
            obj.update_shifts([],[]);
            obj.markRealizationStale();
            obj.checkdirty([],[]);
        end

        function updateSampleDataListeners(obj,~,~)
            obj.wireSampleData();
            obj.updateContourListeners([],[]);
            obj.markRealizationStale();
            obj.checkdirty([],[]);
        end

        function markRealizationStale(obj,~,~)
            % options, ell and r (lowering them keeps the samples, see SampleData.activeSamples) and replaced parts change the realization but not the samples
            obj.RealizationData.loaded = false;
        end

        function samplesChanged(obj,~,~)
            % invalidated samples make the realization built from them stale too
            if ~obj.SampleData.loaded && obj.RealizationData.loaded
                obj.RealizationData.loaded = false;   % its PostSet runs checkdirty
            else
                obj.checkdirty([],[]);
            end
        end

        function updateListeners(obj,~,~)
            obj.updateSampleDataListeners([],[]);
            obj.updateRealizationDataListeners([],[]);
        end
        function tf = noContourForShifts(obj)
            % the Loewner shifts are placed around the contour; without one there are none to place
            tf = isempty(obj.SampleData.Contour) && obj.RealizationData.ComputationalMode ~= Numerics.ComputationalMode.Hankel;
        end
        function update_shifts(obj,~,~)
            if ~obj.auto_update_shifts || obj.noContourForShifts()
                return;
            end
            switch obj.RealizationData.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    obj.RealizationData.defaultInterpolationData;
                case Numerics.ComputationalMode.SPLoewner
                    % The single shift sigma must stay OUTSIDE the contour --
                    % a sigma inside Omega adds a spurious pole 1/(sigma-z)^(k+1)
                    % to the moment integrands and silently corrupts the result.
                    % Keep a still-valid shift in place (so dragging the contour
                    % doesn't churn results), and only relocate when sigma is
                    % missing/non-finite or has fallen inside the contour.
                    sigma = obj.RealizationData.InterpolationData.sigma;
                    contour = obj.SampleData.Contour;
                    if isempty(sigma) || ~all(isfinite(sigma)) || contour.inside(sigma(1))
                        obj.RealizationData.InterpolationData = ...
                            Numerics.InterpolationData([], contour.FindShift());
                    end
                case Numerics.ComputationalMode.MPLoewner
                    obj.contour_interlevedshifts();
            end
        end
        function checkdirty(obj,~,~)
            if ~obj.SampleData.loaded
                obj.DataDirtiness = 2;
                %if obj.auto_compute_samples
                %    obj.SampleData.compute();
                %    obj.checkdirty([],[]);
                %end
            elseif ~obj.RealizationData.loaded
                obj.DataDirtiness = 1;
                %if obj.auto_compute_realization
                %    obj.computeRealization();
                %    obj.checkdirty([],[]);
                %end
            else
                obj.DataDirtiness = 0;
            end
        end
    end
end
