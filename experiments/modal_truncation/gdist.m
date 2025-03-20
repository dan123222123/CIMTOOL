function [gd,uc] = gdist(ref,obs,tol)
    gd = zeros(length(obs),1);
    uc = [];
    for i=1:length(obs)
        cl = abs(ref - obs(i));
        [gd(i),idx] = min(cl);
        if any(cl < tol) % has the ew we identified actually "converged" to tol
            ref(idx) = []; % only then, remove it
        else
            uc(end+1) = i;
        end
    end
end

