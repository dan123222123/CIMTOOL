function HerriR = l2e(H,Hr,w)
    arguments
        H 
        Hr
        w = logspace(-6,6,5000);
    end
    Herr = @(z) H(z) - Hr(z);
    HerriR = arrayfun(Herr,1i*w,'UniformOutput',false);
    HerriR = cat(3,HerriR{:});
    HerriR = pagenorm(HerriR);
    HerriR = HerriR(:);
end

