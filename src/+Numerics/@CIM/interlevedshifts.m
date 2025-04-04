% using the underlying quadrature
% determine the geometric center and the maximum distance
% between the center and a quadrature node.
% then scale that distance and interleve the nodes on a
% circle with geo center and max_dist*scale
function interlevedshifts(obj)
    nsw = obj.RealizationData.K;
    d = obj.RealizationData.ShiftScale;
    [theta,sigma] = obj.SampleData.Contour.interlevedshifts(nsw,d);
    obj.RealizationData.InterpolationData = Numerics.InterpolationData(theta,sigma);
end