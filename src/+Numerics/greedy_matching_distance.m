function [nmd,gd] = greedy_matching_distance(ref,obs,p)
    arguments
        ref 
        obs 
        p = 2
    end
    % first, sort obs by magnitude -- matching observed ew from the largest
    % magnitude will give some consistency and (hopefully) make the
    % greedy matching distance more reasonable
    [~,obsidx] = sort(abs(obs)); obs = obs(obsidx);
    gd = zeros(length(obs),1);
    for i=1:length(obs)
        cl = abs(ref - obs(i));
        [gd(i),idx] = min(cl);
        ref(idx) = [];
    end
    nmd = norm(gd,p);
end

