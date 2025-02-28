function ellrrank(dpath,CIM,x,H,w)

    rarr = zeros(length(x),1); % Db rank
    ewrrarr = zeros(length(x),1); % computed ew relative residual
    L2pe = zeros(length(x),1); % L2 error vs H
    for i=1:length(x)
        CIM.SampleData.ell = x(i); CIM.SampleData.r = x(i);
        CIM.compute();
        %
        rarr(i) = Numerics.rankdet(CIM.ResultData.Db);
        ewrrarr(i) = mean(Numerics.relres(CIM.SampleData.NLEVP.T,CIM.ResultData.ew,CIM.ResultData.rev));
        L2pe(i) = max(l2e(H,rtf(CIM),w));
        fprintf("done with %d\n",i);
    end
    figure(1);
    plot(x,rarr); title(gca, "Db Rank vs ell/r");
    saveas(gcf,strcat(dpath,"/dbr_ellr.png"));
    %
    figure(2);
    plot(x,ewrrarr); title(gca, "Mean EW Relative Residual vs ell/r");
    saveas(gcf,strcat(dpath,"/mewrr_ellr.png"));
    %
    figure(3);
    semilogy(x,L2pe); title(gca, "Max L2 Frequency Error vs N");
    saveas(gcf,strcat(dpath,"/ml2fe_ellr.png"));
    
    close all;

end