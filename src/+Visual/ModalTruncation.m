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
