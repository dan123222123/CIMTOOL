function H = rtf(CIM)
    m = CIM.RealizationData.m;
    [~,V2,W2,M21,M22] = CIM.ResultData.rtf(m);
    H = @(z) V2*((M21-z*M22)\W2); 
end