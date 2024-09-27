classdef Data < handle
    
    properties
        Ql          (:,:,:) double
        Qr          (:,:,:) double
        Qlr         (:,:,:) double
        Parameters  Sample.Parameters
    end
    
    methods

        % listener for changes to Parameters.L/Parameters.R
        % Then, resample Ql,Qr,Qlr as necessary



    end

end

