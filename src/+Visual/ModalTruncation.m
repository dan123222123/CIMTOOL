classdef ModalTruncation < Numerics.ModalTruncation & Visual.VisualReactive
% MODALTRUNCATION Visual wrapper for modal truncation with reactive plotting
%
% Extends Numerics.ModalTruncation with visualization capabilities.
% Plots eigenvalues and contour for the region approximation.

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = copyElement@Numerics.ModalTruncation(obj);
            cp.ax = obj.ax;
        end
    end

    methods (Static)
        function v = fromNumerics(n, ax)
            % FROMNUMERICS Construct a Visual.ModalTruncation from a Numerics.ModalTruncation.
            arguments
                n Numerics.ModalTruncation
                ax = []
            end
            v_region = Visual.CIM.fromNumerics(n.RegionCIM, ax);
            v = Visual.ModalTruncation(n.FullTransferFunction, ...
                v_region.SampleData.Contour, v_region.RealizationData, ax);
            v.RegionCIM = v_region;
            Visual.copyMatchingProperties(n, v, "RegionCIM");
        end
    end

    methods
        function obj = ModalTruncation(H, Contour, RealizationData, ax)
            % Constructor for Visual.ModalTruncation
            %
            % Inputs:
            %   H               - Transfer function handle (required)
            %   Contour         - Any Visual.Contour.* object (default: Circle)
            %   RealizationData - Visual.RealizationData (default: new instance)
            %   ax              - Axes handle for plotting (default: [])
            arguments
                H                   % Transfer function handle
                Contour = Visual.Contour.Circle()
                RealizationData = Visual.RealizationData()
                ax = []
            end
            import Visual.*

            % Create OperatorData from function handle
            opData = Visual.OperatorData(H);

            % Create CIM for region approximation with Visual components
            obj.FullTransferFunction = H;
            obj.RegionCIM = Visual.CIM(opData, Contour, RealizationData);

            obj.ax = ax;
            obj.update_plot([],[]);
        end

        function n = toNumerics(obj)
            % TONUMERICS Strip visual state and return a Numerics.ModalTruncation.
            n_region = obj.RegionCIM.toNumerics();
            n = Numerics.ModalTruncation(obj.FullTransferFunction, ...
                n_region.SampleData.Contour, n_region.RealizationData);
            n.RegionCIM = n_region;
            Visual.copyMatchingProperties(obj, n, "RegionCIM");
        end

        function update_plot(obj,~,~)
            ax = obj.ax;
            if isempty(ax)
                ax = {[]};
            elseif ~iscell(ax)
                ax = num2cell(ax);
            end
            obj.RegionCIM.ax = ax{1};
            obj.phandles = obj.RegionCIM.phandles;
        end

        function phandles = plot(obj,ax)
            % Plot the modal truncation (eigenvalues and contour)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax); return; end
            if ~iscell(ax); ax = num2cell(ax); end

            % Plot the underlying CIM (contour + eigenvalues)
            phandles = [phandles obj.RegionCIM.plot(ax{1})];
        end
    end
end
