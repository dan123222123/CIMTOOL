function l = weakListener(src, prop, owner, callback)
% PostSet listener on src.(prop) that calls callback(owner, src, event) without keeping owner alive.
    ref = matlab.lang.WeakReference(owner);
    l = addlistener(src, prop, 'PostSet', @(s, e) callIfAlive(ref, callback, s, e));
end

function callIfAlive(ref, callback, s, e)
    owner = ref.Handle;
    if isvalid(owner)
        callback(owner, s, e);
    end
end
