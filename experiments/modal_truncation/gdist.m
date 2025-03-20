function gd = gdist(ref,obs)
    gd = zeros(length(obs),1);
    for i=1:length(obs)
        [gd(i),idx] = min(abs(ref - obs(i)));
        ref(idx) = [];
    end
end

