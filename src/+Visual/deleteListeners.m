function deleteListeners(listeners)
% DELETELISTENERS Safely delete an array of listener handles.
%
% Iterates over the given listener array and deletes each valid handle,
% ignoring any errors (e.g. already-deleted handles). This is a shared
% utility used by VisualReactive and GUI components for listener cleanup.
%
% Usage:
%   Visual.deleteListeners(obj.listeners);
    try
        for i = 1:length(listeners)
            if isvalid(listeners(i))
                delete(listeners(i));
            end
        end
    catch
    end
end
