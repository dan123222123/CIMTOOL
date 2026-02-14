classdef ModalTruncation < matlab.mixin.Copyable
% MODALTRUNCATION Coordinate modal truncation workflow using contour integral methods
%
% Modal truncation approximates the spectrum of a transfer function within
% a user-chosen contour region, enabling isolation of spectral regions.
%
% Workflow:
%   1. Given: Transfer function H(z) (function handle)
%   2. User chooses contour to select spectral region
%   3. CIM approximates H_region(z) for spectrum inside contour
%   4. Residual H_residual(z) = H(z) - H_region(z) isolates complement
%
% Example:
%   H = @(z) ...; % Full transfer function
%   contour = Numerics.Contour.CircularSegment(0, 1, [-pi/2, pi/2], [32;32]);
%   mt = Numerics.ModalTruncation(H, contour);
%   mt.compute();
%   H_region = mt.getRegionTransferFunction();
%   H_residual = mt.getResidualTransferFunction();

    properties (SetObservable)
        FullTransferFunction    % Function handle H(z) for full system
        RegionCIM              % CIM object for approximating spectral region
        RegionTF               % Approximated transfer function for region
        ResidualTF             % H(z) - H_region(z)
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.ModalTruncation(obj.FullTransferFunction);
            cp.RegionCIM = copy(obj.RegionCIM);
            cp.RegionTF = obj.RegionTF;
            cp.ResidualTF = obj.ResidualTF;
        end
    end

    methods
        function obj = ModalTruncation(H, Contour, RealizationData)
            % Constructor for ModalTruncation
            %
            % Inputs:
            %   H               - Transfer function handle (required)
            %   Contour         - Any Numerics.Contour.* object (default: Circle)
            %   RealizationData - Numerics.RealizationData (default: new instance)
            arguments
                H                   % Transfer function handle
                Contour = Numerics.Contour.Circle()
                RealizationData = Numerics.RealizationData()
            end

            obj.FullTransferFunction = H;

            % Create OperatorData from function handle
            opData = Numerics.OperatorData(H);
            opData.sample_mode = "Direct"; % didn't bake in an easy way to set this in the constructor...

            % Create CIM for region approximation
            obj.RegionCIM = Numerics.CIM(opData, Contour, RealizationData);
        end

        function compute(obj)
            % Compute the modal truncation
            %
            % Steps:
            %   1. Compute CIM approximation for the region
            %   2. Build transfer function for region
            %   3. Build residual transfer function

            % Compute CIM approximation
            obj.RegionCIM.compute();

            % Build transfer function for region from results
            obj.RegionTF = obj.RegionCIM.ResultData.getTransferFunction();

            % Build residual transfer function
            H_full = obj.FullTransferFunction;
            H_region = obj.RegionTF;
            obj.ResidualTF = @(z) H_full(z) - H_region(z);
        end

        function H_region = getRegionTransferFunction(obj)
            % Returns approximation of spectrum inside contour
            if isempty(obj.RegionTF)
                error('ModalTruncation:NotComputed', 'Must call compute() first');
            end
            H_region = obj.RegionTF;
        end

        function H_residual = getResidualTransferFunction(obj)
            % Returns transfer function with region removed
            % H_residual(z) = H(z) - H_region(z)
            if isempty(obj.ResidualTF)
                error('ModalTruncation:NotComputed', 'Must call compute() first');
            end
            H_residual = obj.ResidualTF;
        end

        function ew = getRegionEigenvalues(obj)
            % Returns computed eigenvalues in the region
            ew = obj.RegionCIM.ResultData.ew;
        end

        function setContour(obj, Contour)
            % Change the contour (e.g., from Circle to CircularSegment)
            obj.RegionCIM.SampleData.Contour = Contour;
        end

        function setRealizationData(obj, RealizationData)
            % Update realization parameters
            obj.RegionCIM.RealizationData = RealizationData;
        end
    end
end
