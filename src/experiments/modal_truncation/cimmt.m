function H = cimmt(CIM,m) % static method to separate Lambda, V, and W from CIM struct changes
    [Lambda,V,W] = CIM.ResultData.rtfm(m); H = @(z) V*((Lambda-z*eye(size(Lambda)))\W);
end

