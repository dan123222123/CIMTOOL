function contour_interlevedshifts(obj,ShiftScale,ShiftType)
    arguments
        obj 
        ShiftScale = 1.25
        ShiftType = 'scale'
    end
    T1 = obj.RealizationData.RealizationSize.T1; T2 = obj.RealizationData.RealizationSize.T2;
    [theta,sigma] = obj.SampleData.Contour.interlevedshifts(max(T1,T2),ShiftScale,ShiftType);
    obj.RealizationData.InterpolationData = Numerics.InterpolationData(theta,sigma);
end