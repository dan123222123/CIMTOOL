function [nmd,gd] = greedyMatchingDistance(obj)
    
    if obj.DataDirtiness
        error("Data is dirty, computing matching distances in this condition doesn't make sense...")
    end

    refew = obj.SampleData.OperatorData.refew;

    if isempty(refew)
        error("no reference eigenvalue data in CIM, cannot computer GMD...")
    end

    [nmd,gd] = Numerics.greedy_matching_distance(refew,obj.ResultData.ew);
    
end