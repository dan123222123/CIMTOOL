% if cmp
function [nmderr,pairedeigs] = normmderr(refeig,cmpeig)

    n = length(refeig); m = length(cmpeig); nm = min(n,m);

    if n >= 10
        error("This will take too long...")
    end

    % we must check all possible permutations of the reference eigenvalues
    refidxperms = perms(1:n); nmderr = Inf;
    
    pairedrefeig = zeros(nm,1); pairedcmpeig = zeros(nm,1);

    for p = 1:size(refidxperms,1)

        % permute refeig and copy cmpeig to pcmpeig
        prefeig = refeig(refidxperms(p,:)); pcmpeig = cmpeig;

        % vector of errors between optimal pairings of prefeig and pcmpeig
        cmderr = zeros(n,1);

        % vector of paired computed eigenvalues for current prefeig
        cpairedcmpeig = zeros(nm,1);

        % for each reference eigenvalue in prefeig
        for i = 1:n

            % we don't need to continue if there are no eigs left to pair
            mm = length(pcmpeig);
            if mm == 0
                break
            end

            crefeig = prefeig(i);
            % find the closest computed eigenvalue to crefeig
            cmd = zeros(mm,1);
            for j=1:mm
                cmd(j) = abs(crefeig-pcmpeig(j));
            end
            [mincmd,mincmdidx] = min(cmd);
            cmderr(i) = mincmd;
            cpairedcmpeig(i) = pcmpeig(mincmdidx);
            % remove the paired eigenvalue from pcmpeig -- don't double
            % count!
            pcmpeig(mincmdidx) = [];
        end
        cnmderr = norm(cmderr);
        if cnmderr < nmderr
            nmderr = cnmderr;
            pairedcmpeig = cpairedcmpeig;
            pairedrefeig = prefeig;
        end
    end

    pairedeigs = [pairedrefeig pairedcmpeig];

end