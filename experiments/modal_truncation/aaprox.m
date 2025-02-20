function aa = aaprox(ew,x)
    [~,lmidx] = max(abs(ew)); 
    a0 = - real(ew(lmidx));

    aa = a0;
    for i=1:length(ew)
        aa = aa + 2*(a0 + real(ew(i)))*cos(2*i*pi*x);
    end
    
end

