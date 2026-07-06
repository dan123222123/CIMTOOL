function v = padnan(v, n)
% PADNAN  Pad a vector with trailing NaN to length n (column output).
%   v = padnan(v, n) returns [v(:); NaN(...)] so the result has exactly n rows
%   when numel(v) <= n, and is a no-op (never truncates) otherwise. Used to
%   line up unequal-length table columns without depending on padarray / the
%   Image Processing Toolbox.
    v = [v(:); NaN(max(0, n - numel(v)), 1)];
end
