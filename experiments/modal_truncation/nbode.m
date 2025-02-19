function nbode(H,w)
    arguments
        H 
        w = []
    end
    if isempty(w)
        w = logspace(-6,6,5000);
    end
    Hw = arrayfun(H,1i*w,'UniformOutput',false);
    Hw = cat(3,Hw{:}); Hw = pagenorm(Hw); Hw = Hw(:);
    loglog(w,Hw);
end
    