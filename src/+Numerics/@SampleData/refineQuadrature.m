function refineQuadrature(obj)

    if ~(obj.OperatorData.loaded && obj.loaded)
        error(sprintf("Contour/NLEVP sample data not loaded.\n Please 'compute' before refining the quadrature."))
    end

    % now assumed that the full sampling data is reflective of the
    % un-refined contour
    obj.loaded = false;

    % N = obj.Contour.N;
    obj.Contour.refineQuadrature(2);
    zadded = obj.Contour.z(1:2:end);
    N = length(zadded);

    [Qladded,Qradded,Qlradded] = obj.samplequadrature(obj.OperatorData.T,obj.Lf,obj.Rf,zadded,obj.show_progress,obj.OperatorData.sample_mode);

    Qlnew   = zeros(size(obj.Ql,1),size(obj.Ql,2),2*N);
    Qrnew   = zeros(size(obj.Qr,1),size(obj.Qr,2),2*N);
    Qlrnew  = zeros(size(obj.Qlr,1),size(obj.Qlr,2),2*N);

    for i=1:N
        Qlnew(:,:,2*i-1)    = Qladded(:,:,i);
        Qlnew(:,:,2*i)      = obj.Ql(:,:,i);
        %
        Qrnew(:,:,2*i-1)    = Qradded(:,:,i);
        Qrnew(:,:,2*i)      = obj.Qr(:,:,i);
        %
        Qlrnew(:,:,2*i-1)   = Qlradded(:,:,i);
        Qlrnew(:,:,2*i)     = obj.Qlr(:,:,i);
    end

    obj.Ql = Qlnew;
    obj.Qr = Qrnew;
    obj.Qlr = Qlrnew;

    obj.loaded = true;

end