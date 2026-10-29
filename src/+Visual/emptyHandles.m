function h = emptyHandles()
% An empty array of graphics handles: gobjects(0), or [] where the graphics classes are unavailable
% (a thread-based parallel worker), so Visual objects can still be built and computed there.
    try
        h = gobjects(0);
    catch
        h = [];
    end
end
