function [m,d] = findrankdrop(sw,offset)
arguments
    sw 
    offset = 1
end
    d = Inf;
    m = 1;
    for i=1:length(sw)-offset
        crdr = sw(i+1)/sw(i);
        if d > crdr
            d = crdr;
            m = i;
        end
    end
end

