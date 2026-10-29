function contour_interlevedshifts(obj,ShiftScale,ShiftType,varargin)
% Sets interleaved shifts from the contour's interlevedshifts (ShiftScale = 1.25, ShiftType = 'scale' by default).
    if nargin < 2; ShiftScale = 1.25; end
    if nargin < 3; ShiftType = 'scale'; end
    T1 = obj.RealizationData.RealizationSize.T1; T2 = obj.RealizationData.RealizationSize.T2;
    [theta,sigma] = obj.SampleData.Contour.interlevedshifts(max(T1,T2),ShiftScale,ShiftType,varargin{:});
    obj.RealizationData.InterpolationData = Numerics.InterpolationData(theta,sigma);
end
