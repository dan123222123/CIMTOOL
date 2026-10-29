function refineQuadrature(obj)

    if isempty(obj.Contour)
        error("Numerics:SampleData:noContour", ...
            "Contour data required to refine the quadrature. Please set a contour and try again.")
    end
    if ~(obj.OperatorData.loaded && obj.loaded)
        error("Numerics:SampleData:notLoaded", ...
            "Contour/NLEVP sample data not loaded.\n Please 'compute' before refining the quadrature.")
    end

    % the cached samples reflect the current (un-refined) contour; snapshot
    % them before the contour's nodes change underneath us
    % refinement keeps only the leading ell and r directions; the samples of
    % further stored directions are dropped, and a larger ell later resamples
    [Qlold,Qrold,Qlrold] = obj.activeSamples();
    Ls = obj.L; Rs = obj.R;
    obj.loaded = false;

    if isa(obj.Contour,'Numerics.Contour.CircularSegment') % covers Visual subclass too
        % Clenshaw-Curtis nests: reuse cached evaluations at the surviving
        % nodes and sample only the new ones. 'reused' is a logical mask over
        % the refined node vector (true = carried over from the old contour, in
        % original order); [] means the rule does not nest -> resample fully.
        reused = obj.Contour.refineQuadrature(2);
        if isempty(reused)
            return; % leave loaded=false so the next compute() resamples fully
        end
        zadded = obj.Contour.z(~reused);
        [Qladded,Qradded,Qlradded] = obj.samplequadrature(obj.OperatorData.T,Ls,Rs,zadded,obj.show_progress,obj.OperatorData.sample_mode);

        L = numel(reused);
        Qlnew  = zeros(size(Qlold,1),  size(Qlold,2),  L);
        Qrnew  = zeros(size(Qrold,1),  size(Qrold,2),  L);
        Qlrnew = zeros(size(Qlrold,1), size(Qlrold,2), L);
        Qlnew(:,:,reused)  = Qlold;   Qlnew(:,:,~reused)  = Qladded;
        Qrnew(:,:,reused)  = Qrold;   Qrnew(:,:,~reused)  = Qradded;
        Qlrnew(:,:,reused) = Qlrold;  Qlrnew(:,:,~reused) = Qlradded;

        obj.Ql = Qlnew;
        obj.Qr = Qrnew;
        obj.Qlr = Qlrnew;

        obj.loaded = true;
        return;
    end

    % --- trapezoid contours (Circle/Ellipse): doubling interleaves new nodes
    %     between the old ones, so z(1:2:end) are new and z(2:2:end) reused ----
    obj.Contour.refineQuadrature(2);

    zadded = obj.Contour.z(1:2:end);
    N = length(zadded);

    [Qladded,Qradded,Qlradded] = obj.samplequadrature(obj.OperatorData.T,Ls,Rs,zadded,obj.show_progress,obj.OperatorData.sample_mode);

    Qlnew   = zeros(size(Qlold,1),size(Qlold,2),2*N);
    Qrnew   = zeros(size(Qrold,1),size(Qrold,2),2*N);
    Qlrnew  = zeros(size(Qlrold,1),size(Qlrold,2),2*N);

    for i=1:N
        Qlnew(:,:,2*i-1)    = Qladded(:,:,i);
        Qlnew(:,:,2*i)      = Qlold(:,:,i);
        %
        Qrnew(:,:,2*i-1)    = Qradded(:,:,i);
        Qrnew(:,:,2*i)      = Qrold(:,:,i);
        %
        Qlrnew(:,:,2*i-1)   = Qlradded(:,:,i);
        Qlrnew(:,:,2*i)     = Qlrold(:,:,i);
    end

    obj.Ql = Qlnew;
    obj.Qr = Qrnew;
    obj.Qlr = Qlrnew;

    obj.loaded = true;

end
