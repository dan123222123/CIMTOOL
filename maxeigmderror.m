function merr = maxeigmderror(refew,cew)
    m = length(refew);
    md = zeros(m,1);
    for j = 1:min(m,length(cew))
        cref = refew(j);
        cpd = zeros(length(cew),1);
        for i=1:length(cew)
            cpd(i) = abs(cref-cew(i));
        end
        [cmd,cmdi] = min(cpd);
        md(j) = cmd;
        cew(cmdi) = [];
    end
    merr = norm(md);
end