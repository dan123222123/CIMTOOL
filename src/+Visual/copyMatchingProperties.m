function copyMatchingProperties(src, dst, exclude)
% COPYMATCHINGPROPERTIES Copy shared public properties from src to dst.
%
% Copies every publicly readable, non-dependent property of src that also
% exists as a publicly settable property in dst, skipping names listed in
% exclude. Properties that exist only in one class (e.g. Visual-only ax,
% phandles, plot_quadrature) are silently ignored.
%
% Inputs:
%   src     - Source object
%   dst     - Destination object (modified in place; must be a handle class)
%   exclude - (optional) string array of property names to skip
%
% Usage in fromNumerics / toNumerics:
%   copyMatchingProperties(n, v, ["loaded","SomeObjectProp"]);
%   v.loaded = n.loaded;  % set ordering-sensitive props explicitly after
    arguments
        src
        dst
        exclude (1,:) string = string.empty
    end

    % properties() returns public, non-hidden, non-abstract, non-dependent props
    src_props = properties(src);

    % Build set of publicly settable dst property names via metaclass
    dst_meta = metaclass(dst);
    dst_settable = string.empty;
    for p = dst_meta.PropertyList'
        if strcmp(p.SetAccess, 'public') && ~p.Dependent && ~p.Constant
            dst_settable(end+1) = p.Name; %#ok<AGROW>
        end
    end

    for i = 1:numel(src_props)
        name = src_props{i};
        if ismember(name, dst_settable) && ~ismember(name, exclude)
            dst.(name) = src.(name);
        end
    end
end
